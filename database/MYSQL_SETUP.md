# HRSOFT MySQL Setup Guide

Hướng dẫn cài đặt và cấu hình MySQL cho dự án HRSOFT trên Windows.

## 🎯 Tùy chọn cài đặt

### Option 1: XAMPP (Khuyến nghị cho Development)

1. **Download XAMPP**: https://www.apachefriends.org/
2. **Cài đặt**: Chọn MySQL, Apache, phpMyAdmin
3. **Khởi động**: Mở XAMPP Control Panel → Start MySQL
4. **Truy cập**: phpMyAdmin tại http://localhost/phpmyadmin
5. **Test**: Chạy `.\dev.ps1 db-check`

### Option 2: MySQL Server Official

1. **Download**: https://dev.mysql.com/downloads/mysql/
2. **Cài đặt**: MySQL Server + MySQL Workbench
3. **Cấu hình**: Đặt root password khi cài đặt
4. **Khởi động**: MySQL80 service sẽ tự động start
5. **Test**: Chạy `.\dev.ps1 db-check`

### Option 3: Docker MySQL

```powershell
# Tạo MySQL container
docker run --name hrsoft-mysql -e MYSQL_ROOT_PASSWORD=hrsoft123 -p 3306:3306 -d mysql:8.0

# Test connection
.\dev.ps1 db-check
```

## 🚀 Quick Start Commands

```powershell
# 1. Kiểm tra MySQL setup
.\dev.ps1 db-check

# 2. Deploy database schema  
.\dev.ps1 db-deploy

# 3. Start development environment
.\dev.ps1 dev-up
```

## 🔧 Troubleshooting

### Lỗi "Access denied for user 'root'"

1. **Reset MySQL root password**:
   ```sql
   -- Connect to MySQL as root
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'newpassword';
   FLUSH PRIVILEGES;
   ```

2. **Hoặc tạo user mới**:
   ```sql
   CREATE USER 'hrsoft'@'localhost' IDENTIFIED BY 'hrsoft123';
   GRANT ALL PRIVILEGES ON *.* TO 'hrsoft'@'localhost';
   FLUSH PRIVILEGES;
   ```

### Lỗi "Can't connect to MySQL server"

1. **Kiểm tra service**: Services.msc → MySQL80
2. **Khởi động lại**: `net start MySQL80`
3. **Kiểm tra port**: `netstat -an | findstr :3306`

### XAMPP Issues

1. **Port conflict**: Đổi MySQL port trong XAMPP Config
2. **Service not starting**: Chạy XAMPP as Administrator
3. **Permission issues**: Tắt Windows Defender/Antivirus tạm thời

## 📋 Default Credentials

### XAMPP
- **Host**: localhost
- **Port**: 3306  
- **User**: root
- **Password**: (empty)

### MySQL Server
- **Host**: localhost
- **Port**: 3306
- **User**: root  
- **Password**: (set during installation)

### Docker MySQL
- **Host**: localhost
- **Port**: 3306
- **User**: root
- **Password**: hrsoft123

## 🔗 Useful Links

- [MySQL Documentation](https://dev.mysql.com/doc/)
- [XAMPP Documentation](https://www.apachefriends.org/docs.html)
- [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)
- [phpMyAdmin](https://www.phpmyadmin.net/)

## 🎯 Next Steps

Sau khi cài đặt MySQL thành công:

1. Chạy `.\dev.ps1 db-check` để verify
2. Chạy `.\dev.ps1 db-deploy` để tạo HRSOFT database
3. Chạy `.\dev.ps1 dev-up` để start development environment

Happy coding! 🚀
