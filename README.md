# MongoDB Database Export Scripts

This repository contains cross-platform scripts for exporting MongoDB databases using `mongodump` with timestamp-based folder naming for development usage.

## Files

- `dbexport.sh` - Linux/macOS Bash script
- `dbexport.ps1` - Windows PowerShell script

## Features

✅ **Timestamp-based folder naming**: Creates folders like `dbbackup-20250805132500-qos-bigmenu`  
✅ **Secure credential management**: Uses environment variables instead of hardcoded credentials  
✅ **Automatic directory creation**: Creates backup directories with fallback to Desktop  
✅ **Prerequisites checking**: Verifies `mongodump` is available before running  
✅ **Cross-platform support**: Works on Windows, Linux, and macOS  
✅ **Colored output**: Clear status messages with color coding  
✅ **Error handling**: Graceful error handling with helpful messages  

## Prerequisites

### 1. Install MongoDB Database Tools

#### Windows
```powershell
# Option 1: Using Chocolatey
choco install mongodb-database-tools

# Option 2: Using winget
winget install MongoDB.DatabaseTools

# Option 3: Manual download
# Download from: https://www.mongodb.com/try/download/database-tools
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install mongodb-database-tools
```

#### Linux (CentOS/RHEL)
```bash
sudo yum install mongodb-database-tools
```

#### macOS
```bash
brew install mongodb/brew/mongodb-database-tools
```

### 2. Set Environment Variables

#### Windows PowerShell
```powershell
# For current user
[Environment]::SetEnvironmentVariable('MONGODB_USERNAME', 'db_username', 'User')
[Environment]::SetEnvironmentVariable('MONGODB_PASSWORD', 'db_password', 'User')
[Environment]::SetEnvironmentVariable('MONGODB_HOST', '192.168.1.10', 'User')
[Environment]::SetEnvironmentVariable('MONGODB_PORT', '27018', 'User')

# For system-wide (requires Administrator)
[Environment]::SetEnvironmentVariable('MONGODB_USERNAME', 'db_username', 'Machine')
[Environment]::SetEnvironmentVariable('MONGODB_PASSWORD', 'db_password', 'Machine')
[Environment]::SetEnvironmentVariable('MONGODB_HOST', '192.168.1.10', 'Machine')
[Environment]::SetEnvironmentVariable('MONGODB_PORT', '27018', 'Machine')
```

#### Linux/macOS Bash
```bash
# Add to ~/.bashrc or ~/.profile
export MONGODB_USERNAME=db_username
export MONGODB_PASSWORD=db_password
export MONGODB_HOST=192.168.1.10
export MONGODB_PORT=27018

# Apply changes
source ~/.bashrc
```

## Usage

### Windows
```powershell
# Run the export script
.\dbexport.ps1

# Show help
.\dbexport.ps1 -Help
```

### Linux/macOS
```bash
# Make script executable (first time only)
chmod +x dbexport.sh

# Run the export script
./dbexport.sh
```

## Output

The scripts will:

1. **Check prerequisites**: Verify `mongodump` is installed and available
2. **Validate credentials**: Check that environment variables are set
3. **Create backup directory**: Generate timestamped folder name
4. **Export database**: Run `mongodump` with the provided credentials
5. **Show results**: Display the exported databases and their location

### Example Output
```
[INFO] MongoDB Database Export Script
[INFO] ==============================
[INFO] Starting MongoDB export...
[INFO] Target directory: /home/user/dbbackup-20250805132500-qos-bigmenu
[SUCCESS] MongoDB export completed successfully!
[INFO] Backup saved to: /home/user/dbbackup-20250805132500-qos-bigmenu
[INFO] Exported databases:
admin/
config/
local/
your-database/
[SUCCESS] Export process completed!
```

## Directory Structure

The export will create a folder structure like:
```
dbbackup-20250805132500-qos-bigmenu/
├── admin/
├── config/
├── local/
└── your-database/
    ├── collection1.bson
    ├── collection1.metadata.json
    ├── collection2.bson
    └── collection2.metadata.json
```

## Security Notes

- **Environment Variables**: Credentials are stored in environment variables instead of being hardcoded in scripts
- **No Credential Exposure**: The scripts never display passwords in output or logs
- **Secure Storage**: Consider using a password manager or secure vault for storing credentials
- **Access Control**: Ensure backup directories have appropriate file permissions

## Troubleshooting

### Common Issues

1. **"mongodump command not found"**
   - Install MongoDB Database Tools (see Prerequisites section)
   - Ensure the tools are added to your PATH environment variable

2. **"MongoDB credentials not found"**
   - Set the required environment variables (see Setup section)
   - Restart your terminal/PowerShell after setting variables

3. **"Cannot create directory"**
   - Check write permissions in current directory
   - Script will automatically fallback to Desktop if current directory fails

4. **"MongoDB export failed"**
   - Verify MongoDB server is running and accessible
   - Check network connectivity to MongoDB host
   - Verify credentials are correct
   - Check MongoDB server logs for connection issues

### Getting Help

- Run `.\dbexport.ps1 -Help` on Windows for detailed usage information
- Check the colored output messages for specific error details
- Verify environment variables are set correctly
- Test MongoDB connectivity manually using `mongodump --help`

## License

These scripts are provided as-is for development purposes. Please ensure you have proper authorization before exporting production databases.
