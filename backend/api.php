<?php
// Izinkan akses dari aplikasi Flutter (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Jika request adalah preflight (OPTIONS), langsung kembalikan OK
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Konfigurasi Database (Ganti sesuai dengan phpMyAdmin Anda)
$servername = "localhost";
$username = "root"; // Default XAMPP username
$password = ""; // Default XAMPP password
$dbname = "hunter_system"; // Nama database di phpMyAdmin

// 1. Buat koneksi ke database MySQL
$conn = new mysqli($servername, $username, $password);

// Periksa koneksi
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Koneksi database gagal: " . $conn->connect_error]));
}

// 2. Buat database dan tabel secara otomatis jika belum ada
$conn->query("CREATE DATABASE IF NOT EXISTS $dbname");
$conn->select_db($dbname);

$table_sql = "CREATE TABLE IF NOT EXISTS users (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    passwordHash VARCHAR(255) NOT NULL,
    level INT(11) DEFAULT 1,
    exp INT(11) DEFAULT 0,
    gold INT(11) DEFAULT 100
)";
$conn->query($table_sql);

// 3. Menangani Request dari Flutter
// Baca body request JSON dari Flutter
$data = json_decode(file_get_contents("php://input"));

if (isset($data->action)) {
    $action = $data->action;
    $user = $conn->real_escape_string($data->username);
    $pass = $conn->real_escape_string($data->passwordHash);

    if ($action == "register") {
        // Cek apakah username sudah ada
        $check = $conn->query("SELECT * FROM users WHERE username='$user'");
        if ($check->num_rows > 0) {
            echo json_encode(["status" => "error", "message" => "Username Sudah Ada"]);
            exit();
        }

        // Insert user baru
        $sql = "INSERT INTO users (username, passwordHash, level, exp, gold) VALUES ('$user', '$pass', 1, 0, 100)";
        if ($conn->query($sql) === TRUE) {
            echo json_encode(["status" => "success", "message" => "Register Berhasil"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal menyimpan: " . $conn->error]);
        }
    } 
    
    else if ($action == "login") {
        // Cari user dengan username dan password yang cocok
        $sql = "SELECT * FROM users WHERE username='$user' AND passwordHash='$pass'";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $user_data = $result->fetch_assoc();
            echo json_encode([
                "status" => "success", 
                "message" => "Login Berhasil",
                "data" => [
                    "username" => $user_data["username"],
                    "level" => $user_data["level"],
                    "gold" => $user_data["gold"]
                ]
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Username atau Password salah"]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Action tidak ditemukan"]);
}

$conn->close();
?>
