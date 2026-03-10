const express = require('express');
const mongoose = require('mongoose');
const http = require('http');
const socketIo = require('socket.io');
const session = require('express-session'); // Sessiya qo'shildi

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// --- MONGODB MODELI ---

const driverSchema = new mongoose.Schema({
    login: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    driverName: String,
    carModel: String, 
    carNumber: String,
    isOnline: { type: Boolean, default: false },
    subscriptionUntil: { 
        type: Date, 
        default: () => new Date(+new Date() + 30*24*60*60*1000) 
    },
    statistics: {
        todayEarned: { type: Number, default: 0 },
        totalTrips: { type: Number, default: 0 }
    },
    currentLocation: {
        lat: { type: Number, default: 0 },
        lon: { type: Number, default: 0 }
    },
    lastActive: { type: Date, default: Date.now }
});

const customerSchema = new mongoose.Schema({
    phone: { type: String, unique: true },
    name: String,
    balls: { type: Number, default: 0 }
});

const Driver = mongoose.model('Driver', driverSchema);
const Customer = mongoose.model('Customer', customerSchema);

// MongoDB-ga ulanish
mongoose.connect('mongodb://localhost:27017/taksi_db')
    .then(() => {
        console.log("Ma'lumotlar bazasiga ulandi! ✅");
        createInitialAdmin(); 
    })
    .catch(err => console.log("Baza ulanishida xato: ", err));

app.set('view engine', 'ejs');
app.use(express.static('public'));
app.use(express.json()); 
app.use(express.urlencoded({ extended: true }));

// Sessiya sozlamalari (Mijozni tanib olish uchun)
app.use(session({
    secret: 'eltaksi_secret_key',
    resave: false,
    saveUninitialized: true
}));

// --- YO'LLARI (ROUTES) ---

app.get('/', (req, res) => res.render('index'));

// --- MIJOZ TUGMASI BOSILGANDA SHU YERGA KELADI ---
app.get('/mijoz', (req, res) => {
    res.render('mijoz'); // views/mijoz.ejs faylini ochadi
});

// Mijoz ma'lumotlarini qabul qilish va dashboardga yuborish
app.post('/dashboard-mijoz', async (req, res) => {
    const { name, phone } = req.body;
    try {
        let customer = await Customer.findOne({ phone: phone });
        if (!customer) {
            customer = await Customer.create({ name: name, phone: phone });
        }
        req.session.customerId = customer._id;
        res.redirect('/dashboard');
    } catch (err) {
        res.send("Xatolik yuz berdi");
    }
});

// Dashboard: Mijoz oynasi
app.get('/dashboard', async (req, res) => {
    try {
        // Agar mijoz hali ism-tel kiritmagan bo'lsa, /mijoz sahifasiga yuboramiz
        if (!req.session.customerId) {
            return res.redirect('/mijoz');
        }

        const customer = await Customer.findById(req.session.customerId);
        if (!customer) return res.redirect('/mijoz');

        const activeDrivers = await Driver.find({ isOnline: true });
        const availableCars = [...new Set(activeDrivers.map(d => d.carModel))];

        res.render('dashboard', { customer: customer, availableCars: availableCars });
    } catch (err) {
        res.status(500).send("Xatolik yuz berdi.");
    }
});

app.get('/login', (req, res) => res.render('login'));

app.post('/driver-login', async (req, res) => {
    const { login, password } = req.body;
    try {
        const driver = await Driver.findOne({ login: login, password: password });
        if (driver) {
            res.redirect(`/driver-dashboard?id=${driver._id}`);
        } else {
            res.send("<h1>Xato: Login yoki parol noto'g'ri!</h1><a href='/login'>Orqaga</a>");
        }
    } catch (err) { res.status(500).send("Serverda xato."); }
});

app.get('/driver-dashboard', async (req, res) => {
    const driverId = req.query.id;
    if (!driverId) return res.redirect('/login');
    try {
        const foundDriver = await Driver.findById(driverId);
        if (foundDriver) {
            // Dashboardga kirganda obunani tekshirish
            const isExpired = foundDriver.subscriptionUntil < new Date();
            res.render('driver-dashboard', { driver: foundDriver, isExpired: isExpired });
        } else {
            res.redirect('/login');
        }
    } catch (err) { res.redirect('/login'); }
});

async function createInitialAdmin() {
    const check = await Driver.findOne({ login: 'admin' });
    if (!check) {
        await Driver.create({
            login: 'admin', password: '123',
            driverName: 'Ali Valiev', carModel: 'Gentra', carNumber: '01 A 777 AA',
            subscriptionUntil: new Date(+new Date() + 365*24*60*60*1000) // Admin 1 yil
        });
        console.log("Test haydovchi yaratildi: admin / 123 🔑");
    }
}

// --- SOCKET.IO ---

let onlineDrivers = [];

io.on('connection', (socket) => {
    
    socket.on('driver_online', async (data) => {
        try {
            const driver = await Driver.findById(data.driverId);
            if (!driver) return;

            if (driver.subscriptionUntil < new Date()) {
                return socket.emit('subscription_expired', { 
                    message: "Obuna muddati tugagan! Iltimos, to'lov qiling." 
                });
            }

            socket.driverId = data.driverId; // Uzilganda ishlatish uchun
            if (!onlineDrivers.includes(data.driverId)) {
                onlineDrivers.push(data.driverId);
            }
            await Driver.findByIdAndUpdate(data.driverId, { isOnline: true });
            
            const position = onlineDrivers.indexOf(data.driverId) + 1;
            socket.emit('queue_position', { position: position });
            io.emit('update_available_cars');
        } catch (err) { console.log(err); }
    });

    socket.on('driver_offline', async (data) => {
        const id = data.driverId || socket.driverId;
        onlineDrivers = onlineDrivers.filter(i => i !== id);
        await Driver.findByIdAndUpdate(id, { isOnline: false });
        io.emit('update_available_cars');
    });

    socket.on('new_order', (orderData) => {
        io.emit('push_order_to_drivers', orderData);
    });

    socket.on('accept_order', async (data) => {
        try {
            const roomName = `trip_${data.driverId}`;
            socket.join(roomName);
            const driver = await Driver.findById(data.driverId);
            
            io.emit('order_accepted', {
                driverId: data.driverId,
                driverName: driver.driverName,
                carModel: driver.carModel,
                carNumber: driver.carNumber,
                roomName: roomName
            });
        } catch (err) { console.log(err); }
    });

    socket.on('taximeter_started', (data) => {
        io.to(`trip_${data.driverId}`).emit('notify_taximeter_on', { 
            message: "Haydovchi taksometrni yoqdi. Safar boshlandi! ✅" 
        });
    });

    socket.on('join_trip_room', (data) => {
        socket.join(data.roomName);
    });

    socket.on('finish_trip_and_pay', async (data) => {
        const roomName = `trip_${data.driverId}`;
        io.to(roomName).emit('display_receipt', {
            total: data.amount,
            message: "Safar yakunlandi. Rahmat!"
        });

        try {
            await Driver.findByIdAndUpdate(data.driverId, {
                $inc: { 'statistics.todayEarned': data.amount, 'statistics.totalTrips': 1 }
            });
            await Customer.findByIdAndUpdate(socket.customerId, { $inc: { balls: 1 } });
        } catch (err) { console.log(err); }
    });

    socket.on('disconnect', async () => {
        if (socket.driverId) {
            onlineDrivers = onlineDrivers.filter(id => id !== socket.driverId);
            await Driver.findByIdAndUpdate(socket.driverId, { isOnline: false });
            io.emit('update_available_cars');
        }
    });
});

const PORT = 3000;
server.listen(PORT, () => console.log(`🚀 Server http://localhost:${PORT} da ishlamoqda`));