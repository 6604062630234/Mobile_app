const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const saltRounds = 10;

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

// API สำหรับลงทะเบียน (Sign Up)
app.post('/register', async (req, res) => {
    const { email, password } = req.body;

    try {
        // 1. ตรวจสอบว่ามีอีเมลนี้ในระบบหรือยัง
        const checkQuery = 'SELECT * FROM user_credentials WHERE email = ?';
        db.query(checkQuery, [email], async (err, result) => {
            if (result.length > 0) {
                return res.json({ status: 'error', message: 'Email already exists' });
            }

            // 2. เข้ารหัสรหัสผ่านก่อนบันทึก
            const hashedPassword = await bcrypt.hash(password, saltRounds);

            // 3. บันทึกลง Database
            const insertQuery = 'INSERT INTO user_credentials (email, password) VALUES (?, ?)';
            db.query(insertQuery, [email, hashedPassword], (err, result) => {
                if (err) {
                    return res.status(500).json({ status: 'error', message: err.message });
                }
                res.json({ status: 'success', message: 'User registered successfully' });
            });
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: 'Server error' });
    }
});

//API สำหรับเช็ค Login
app.post('/login', (req, res) => {
    const { email, password } = req.body;
    const query = 'SELECT * FROM user_credentials WHERE email = ?';

    db.query(query, [email], async (err, result) => {
        if (err) return res.status(500).json({ status: 'error', message: err.message });

        if (result.length > 0) {
            // ใช้ bcrypt.compare เพื่อเทียบรหัสผ่านที่รับมา กับรหัสที่เข้ารหัสไว้ใน DB
            const match = await bcrypt.compare(password, result[0].password);
            
            if (match) {
                res.json({ status: 'success', message: 'Login Successful' });
            } else {
                res.json({ status: 'error', message: 'Invalid Password' });
            }
        } else {
            res.json({ status: 'error', message: 'User not found' });
        }
    });
});

app.get('/search-schedules', (req, res) => {

  const { title, email } = req.query;

  const sql = `
    SELECT id, title, description, date, time_start, time_end, color
    FROM schedules
    WHERE email = ?
    AND title LIKE ?
    ORDER BY date ASC, time_start ASC
  `;

  db.query(sql, [email, `%${title}%`], (err, result) => {

    if (err) {
      console.log(err);
      return res.status(500).send(err);
    }

    res.json(result);
  });
});

app.post('/add-schedule', (req, res) => {
    // 1. รับค่า email จาก req.body ที่ส่งมาจาก Flutter
    const { email, date, title, description, time_start, time_end, color } = req.body;

    // 2. ปรับ Query ให้รวมคอลัมน์ email เข้าไปด้วย
    const query = `INSERT INTO schedules (email, date, title, description, time_start, time_end, color) 
                   VALUES (?, ?, ?, ?, ?, ?, ?)`;

    db.query(query, [email, date, title, description, time_start, time_end, color], (err, result) => {
        if (err) {
            console.error('Error saving schedule:', err);
            return res.status(500).json({ status: 'error', message: err.message });
        }
        res.json({ status: 'success', message: 'Schedule added successfully' });
    });
});

app.get('/get-schedules', (req, res) => {

  const { date, email } = req.query;

  const sql = `
    SELECT * FROM schedules
    WHERE date = ?
    AND email = ?
    ORDER BY time_start ASC
  `;

  db.query(sql, [date, email], (err, result) => {

    if (err) {
      return res.status(500).json(err);
    }

    res.json(result);
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
app.use((req, res) => {
    console.log(`มีคนเรียกไปที่ Path: ${req.url} ด้วย Method: ${req.method} แต่หาไม่เจอ!`);
    res.status(404).json({ status: 'error', message: 'Path not found on server' });
});
//สั่งให้ Server ทำงานที่ Port 3000
app.listen(3000, '0.0.0.0', () => {
    console.log('Server runs at http://localhost:3000');
});