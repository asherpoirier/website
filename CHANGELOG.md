# Flux IPTV - Installation Script Changelog

## Version 2.0 (Latest) - November 2024

### 🎉 Major Improvements

#### Automatic Environment Configuration
- ✅ **Auto-creates .env files** - No manual file creation needed
- ✅ **Intelligent defaults** - Uses localhost for development
- ✅ **Smart detection** - Uses existing files if present
- ✅ **Clear feedback** - Shows configuration after creation

#### Python 3.12+ Compatibility (PEP 668)
- ✅ **PEP 668 Compliant** - No more externally-managed-environment errors
- ✅ **System package manager only** - Installs pip via apt/yum
- ✅ **Virtual environment first** - All packages in isolated venv
- ✅ **No get-pip.py** - Removed outdated installation method

#### Ubuntu 24.04 (Noble) Support
- ✅ **MongoDB fix** - Auto-uses Ubuntu 22.04 repository (compatible)
- ✅ **Smart codename detection** - Handles noble → jammy fallback
- ✅ **Error handling** - Graceful failure with helpful messages

#### Enhanced User Experience
- ✅ **Progress indicators** - Clear step-by-step progress
- ✅ **Color-coded output** - Green (success), Yellow (info), Red (error)
- ✅ **Detailed logging** - Know exactly what's happening
- ✅ **Non-interactive option** - Can be automated for CI/CD

### 🔧 Technical Changes

#### Environment File Generation
```bash
# Backend .env (auto-created)
MONGO_URL=mongodb://localhost:27017
DB_NAME=fluxiptv
CORS_ORIGINS=*

# Frontend .env (auto-created)
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=443
REACT_APP_ENABLE_VISUAL_EDITS=false
ENABLE_HEALTH_CHECK=false
```

#### Python Installation Flow
**Before (v1.0):**
```bash
curl get-pip.py → python3 get-pip.py  # ❌ Fails on Python 3.12
```

**After (v2.0):**
```bash
apt-get install python3-pip python3-venv  # ✅ PEP 668 compliant
python3 -m venv venv                      # ✅ Isolated environment
```

#### MongoDB Installation
**Before (v1.0):**
```bash
# Ubuntu 24.04
curl ... noble/mongodb-org/7.0  # ❌ Repository doesn't exist
```

**After (v2.0):**
```bash
# Ubuntu 24.04
UBUNTU_CODENAME="jammy"  # ✅ Use compatible repository
curl ... jammy/mongodb-org/7.0
```

### 📝 New Files

1. **INSTALLATION_GUIDE.md** - Comprehensive installation documentation
2. **CHANGELOG.md** - This file
3. **continue-install.sh** - Recovery script for partial installations
4. **fix-mongodb.sh** - MongoDB repository fix utility
5. **fix-python.sh** - Python environment fix utility
6. **test-install.sh** - Installation verification script

### 🐛 Bug Fixes

1. **Fixed:** Python 3.12 PEP 668 error
   - **Issue:** `externally-managed-environment` error
   - **Solution:** Use apt for pip, virtual environments for packages

2. **Fixed:** Ubuntu 24.04 MongoDB repository
   - **Issue:** MongoDB 7.0 repository not available for noble
   - **Solution:** Use jammy repository (fully compatible)

3. **Fixed:** Missing .env files
   - **Issue:** Installation failed if .env files didn't exist
   - **Solution:** Auto-create with sensible defaults

4. **Fixed:** Inconsistent error messages
   - **Issue:** Unclear error messages
   - **Solution:** Color-coded, detailed status messages

### 📊 Comparison: v1.0 vs v2.0

| Feature | v1.0 | v2.0 |
|---------|------|------|
| Auto-creates .env files | ❌ No | ✅ Yes |
| Python 3.12 compatible | ❌ No | ✅ Yes |
| Ubuntu 24.04 support | ❌ No | ✅ Yes |
| PEP 668 compliant | ❌ No | ✅ Yes |
| Progress indicators | ⚠️ Basic | ✅ Detailed |
| Error handling | ⚠️ Basic | ✅ Comprehensive |
| Recovery scripts | ❌ None | ✅ Multiple |
| Documentation | ⚠️ Basic | ✅ Extensive |

### 🚀 Performance Improvements

- **Faster installation** - Parallel package downloads where possible
- **Smarter caching** - Skips already installed components
- **Reduced redundancy** - No duplicate installations

### 🔒 Security Improvements

- **Virtual environment isolation** - Backend packages isolated
- **System package manager** - More secure than get-pip.py
- **Default CORS settings** - Can be tightened for production

### 📚 Documentation Improvements

- **INSTALLATION_GUIDE.md** - Step-by-step with explanations
- **QUICKSTART.md** - Updated with new features
- **README.md** - Comprehensive overview
- **DEPLOYMENT.md** - Production deployment guide

---

## Version 1.0 - Initial Release

### Features

- Basic dependency installation
- Manual .env file creation required
- Python 3.11 support
- Ubuntu 20.04/22.04 support
- Basic MongoDB installation

### Known Issues

- ❌ Fails on Python 3.12 (PEP 668)
- ❌ Requires manual .env file creation
- ❌ MongoDB fails on Ubuntu 24.04
- ⚠️ Limited error messages

---

## Upgrade Path

### From v1.0 to v2.0

If you installed with v1.0:

1. **Backup existing .env files:**
   ```bash
   cp /app/backend/.env /app/backend/.env.backup
   cp /app/frontend/.env /app/frontend/.env.backup
   ```

2. **Run new installation:**
   ```bash
   cd /app
   sudo bash install.sh
   ```

3. **Script will detect existing .env files and preserve them**

4. **Verify installation:**
   ```bash
   ./test-install.sh
   ```

---

## Future Plans (v3.0)

Planned features for next version:

- [ ] Docker support
- [ ] One-click SSL certificate setup
- [ ] Automatic Nginx configuration
- [ ] Database migration tool
- [ ] Backup automation
- [ ] Health check monitoring
- [ ] Log rotation setup
- [ ] Performance optimization presets

---

## Support

For issues or questions:
- Check [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for detailed help
- Review [QUICKSTART.md](QUICKSTART.md) for common tasks
- See [DEPLOYMENT.md](DEPLOYMENT.md) for production setup
- Contact via Telegram: @customcloudtv

---

**Version 2.0 is a complete rewrite focused on automation, compatibility, and user experience.**
