const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

//ตั้งค่าการเชื่อมต่อ MySQL
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',         
    password: 'K0618649432xyz',         
    database: 'my_schedule'
});

db.connect((err) => {
    if (err) {
        console.error('เชื่อมต่อ MySQL ไม่สำเร็จ: ' + err.stack);
        return;
    }
    console.log('เชื่อมต่อกับ MySQL Database สำเร็จแล้ว!');
});

//API สำหรับเช็ค Login
app.post('/login', (req, res) => {
    console.log("Login request:", req.body);
    const { email, password } = req.body;

    // ค้นหาในตาราง user_credentials
    const query = 'SELECT * FROM user_credentials WHERE email = ? AND password = ?';
    
    db.query(query, [email, password], (err, result) => {
        if (err) {
            return res.status(500).json({ status: 'error', message: err.message });
        }
        
        if (result.length > 0) {
            // ถ้าเจอข้อมูล (Login สำเร็จ)
            res.json({ status: 'success', message: 'Login Successful' });
        } else {
            // ถ้าไม่เจอข้อมูล (Email หรือ Password ผิด)
            res.json({ status: 'error', message: 'Invalid Email or Password' });
        }
    });
});

app.post('/add-schedule', (req, res) => {
    const { date, title, description, time_start, time_end, color } = req.body;

    const query = `INSERT INTO schedules (date, title, description, time_start, time_end, color) 
                   VALUES (?, ?, ?, ?, ?, ?)`;

    db.query(query, [date, title, description, time_start, time_end, color], (err, result) => {
        if (err) {
            console.error('Error saving schedule:', err);
            return res.status(500).json({ status: 'error', message: err.message });
        }
        res.json({ status: 'success', message: 'Schedule added successfully' });
    });
});

app.get('/get-schedules', (req, res) => {
    const { date } = req.query; // รับวันที่มาจาก Flutter
    const query = 'SELECT * FROM schedules WHERE date = ? ORDER BY time_start ASC';

    db.query(query, [date], (err, results) => {
        if (err) return res.status(500).json(err);
        res.json(results); // ส่งรายการข้อมูลกลับไป
    });
});

app.put('/update-schedule/:id', (req, res) => {

  const id = req.params.id;

  const { date, title, description, time_start, time_end, color } = req.body;

  const sql = `
    UPDATE schedules 
    SET date=?, title=?, description=?, time_start=?, time_end=?, color=? 
    WHERE id=?
  `;

  db.query(
    sql,
    [date, title, description, time_start, time_end, color, id],
    (err, result) => {

      if (err) {
        console.log(err);
        return res.status(500).json({ status: "error" });
      }

      res.json({ status: "success" });
    }
  );
});

app.post("/delete-schedule", (req, res) => {

  const { id } = req.body;

  db.query(
    "DELETE FROM schedules WHERE id = ?",
    [id], (err) => {
      res.json({ status: "success" });
    }
  );
});

//สั่งให้ Server ทำงานที่ Port 3000
app.listen(3000, '0.0.0.0', () => {
    console.log('Server runs at http://localhost:3000');
});