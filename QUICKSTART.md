# Flux IPTV - Quick Start Guide

## Installation (One Command)

```bash
chmod +x install.sh && ./install.sh
```

## Start Website

```bash
sudo supervisorctl start all
```

## Access

- **Website**: http://localhost:3000
- **API**: http://localhost:8001/api

## Important Files to Configure

### 1. WHMCS URLs
**File**: `/app/frontend/src/data/mock.js`

```javascript
// Update these URLs with your actual WHMCS links
whmcsLink: "https://your-whmcs-domain.com/cart.php?a=add&pid=1"
```

### 2. Telegram Support
**File**: `/app/frontend/src/data/mock.js`

```javascript
// Already set to @customcloudtv
export const telegramSupportUrl = "https://t.me/customcloudtv";
```

### 3. Logo
**File**: `/app/frontend/src/pages/Home.jsx`

```javascript
// Logo is already configured with your transparent logo
<img src="YOUR_LOGO_URL" alt="Flux IPTV Logo" className="h-16 w-auto" />
```

## Content Customization

All content is in `/app/frontend/src/data/mock.js`:

- **Pricing Plans** - subscriptionPlans array
- **Features** - features array
- **Testimonials** - testimonials array
- **FAQ** - faqs array

## Common Commands

```bash
# Check status
sudo supervisorctl status

# Restart services
sudo supervisorctl restart all
sudo supervisorctl restart frontend
sudo supervisorctl restart backend

# View logs
sudo supervisorctl tail frontend
sudo supervisorctl tail backend

# Stop services
sudo supervisorctl stop all
```

## Project Structure

```
/app
├── install.sh              # Run this first
├── README.md              # Full documentation
├── frontend/
│   ├── src/
│   │   ├── pages/Home.jsx       # Main page
│   │   └── data/mock.js         # Content data
│   └── .env                     # Frontend config
└── backend/
    ├── server.py               # API server
    └── .env                    # Backend config
```

## Support

Need help? Contact via Telegram: @customcloudtv

---

For detailed documentation, see [README.md](README.md)
