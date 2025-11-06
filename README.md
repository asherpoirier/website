# Flux IPTV Website

Professional marketing website for Flux IPTV service with subscription management through WHMCS.

## Features

- **Modern Landing Page** with hero section, features, pricing, testimonials, and FAQ
- **Subscription Plans**: 1, 3, 6, and 12-month options ($10, $25, $45, $80)
- **WHMCS Integration** for payment and subscription management
- **Telegram Support** integration (@customcloudtv)
- **Free 1-Day Trial** option
- **Responsive Design** optimized for all devices
- **Dark Theme** with custom branding

## Tech Stack

- **Frontend**: React 19, TailwindCSS, Shadcn/UI Components
- **Backend**: FastAPI (Python), MongoDB
- **Styling**: Tailwind CSS with custom dark theme
- **Icons**: Lucide React

## Prerequisites

Before installation, ensure you have:

- **Node.js** 16+ ([Download](https://nodejs.org/))
- **Python** 3.8+ ([Download](https://www.python.org/))
- **MongoDB** (local or remote connection)
- **Yarn** package manager (will be installed automatically if missing)

## Quick Start

### 1. Clone or Download the Project

```bash
cd /app
```

### 2. Run Installation Script

```bash
chmod +x install.sh
./install.sh
```

The installation script will:
- Check all prerequisites
- Install backend Python dependencies
- Install frontend npm packages
- Create helper scripts
- Verify environment configuration

### 3. Configure Environment Variables

#### Backend (.env)
Located at `/app/backend/.env`:

```env
MONGO_URL=mongodb://localhost:27017/
DB_NAME=fluxiptv
```

#### Frontend (.env)
Located at `/app/frontend/.env`:

```env
REACT_APP_BACKEND_URL=http://localhost:8001
```

### 4. Configure WHMCS Integration

Edit `/app/frontend/src/data/mock.js` and update the WHMCS URLs:

```javascript
export const subscriptionPlans = [
  {
    id: 1,
    name: "1 Month",
    price: 10,
    whmcsLink: "https://your-whmcs-domain.com/cart.php?a=add&pid=1" // Update this
  },
  // ... update all plans
];

// Update the free trial URL
export const freeTrialWhmcsUrl = "https://your-whmcs-domain.com/cart.php?a=add&pid=trial";
```

### 5. Start the Website

#### Option A: Using Supervisor (Recommended for Production)
```bash
sudo supervisorctl start all
sudo supervisorctl status
```

#### Option B: Using the Start Script (Development)
```bash
./start.sh
```

#### Option C: Manual Start
```bash
# Terminal 1 - Backend
cd /app/backend
source venv/bin/activate
uvicorn server:app --host 0.0.0.0 --port 8001 --reload

# Terminal 2 - Frontend
cd /app/frontend
yarn start
```

### 6. Access the Website

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8001/api
- **API Docs**: http://localhost:8001/docs

## Customization Guide

### Update Logo

Replace the logo URL in `/app/frontend/src/pages/Home.jsx`:

```javascript
<img 
  src="YOUR_LOGO_URL_HERE" 
  alt="Flux IPTV Logo" 
  className="h-16 w-auto"
/>
```

### Update Telegram Support

Edit `/app/frontend/src/data/mock.js`:

```javascript
export const telegramSupportUrl = "https://t.me/YOUR_USERNAME";
```

### Modify Pricing Plans

Edit `/app/frontend/src/data/mock.js` to change prices or add/remove plans.

### Customize Features

Edit the `features` array in `/app/frontend/src/data/mock.js`:

```javascript
export const features = [
  {
    id: 1,
    title: "Your Feature Title",
    description: "Your feature description",
    icon: "Tv" // Lucide icon name
  },
  // Add more features
];
```

### Update Testimonials

Edit the `testimonials` array in `/app/frontend/src/data/mock.js`.

### Modify FAQ

Edit the `faqs` array in `/app/frontend/src/data/mock.js`.

### Change Colors/Styling

Main style files:
- `/app/frontend/src/App.css` - Global styles
- `/app/frontend/src/index.css` - Tailwind configuration
- `/app/frontend/tailwind.config.js` - Tailwind theme

## Project Structure

```
/app
├── backend/
│   ├── server.py              # FastAPI backend
│   ├── requirements.txt       # Python dependencies
│   ├── .env                   # Backend environment variables
│   └── venv/                  # Python virtual environment
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   └── ui/           # Shadcn UI components
│   │   ├── pages/
│   │   │   └── Home.jsx      # Main landing page
│   │   ├── data/
│   │   │   └── mock.js       # Website content data
│   │   ├── App.js            # Main app component
│   │   ├── App.css           # Global styles
│   │   └── index.css         # Tailwind base styles
│   ├── public/
│   │   └── index.html        # HTML template
│   ├── package.json          # npm dependencies
│   ├── tailwind.config.js    # Tailwind configuration
│   └── .env                  # Frontend environment variables
├── install.sh                # Installation script
├── start.sh                  # Start script (created by install.sh)
└── README.md                 # This file
```

## Available Scripts

### Frontend
```bash
cd /app/frontend
yarn start      # Start development server
yarn build      # Build for production
yarn test       # Run tests
```

### Backend
```bash
cd /app/backend
source venv/bin/activate
uvicorn server:app --reload  # Start development server
python -m pytest             # Run tests
```

## Troubleshooting

### Port Already in Use

If port 3000 or 8001 is in use:

```bash
# Find and kill process using the port
sudo lsof -ti:3000 | xargs kill -9
sudo lsof -ti:8001 | xargs kill -9
```

### MongoDB Connection Issues

Check your MongoDB connection string in `/app/backend/.env`:

```env
# For local MongoDB
MONGO_URL=mongodb://localhost:27017/

# For MongoDB Atlas (remote)
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/
```

### Frontend Not Loading

1. Clear cache and rebuild:
```bash
cd /app/frontend
rm -rf node_modules .cache
yarn install
yarn start
```

2. Check logs:
```bash
tail -f /var/log/supervisor/frontend.out.log
tail -f /var/log/supervisor/frontend.err.log
```

### Backend Errors

1. Check Python packages:
```bash
cd /app/backend
source venv/bin/activate
pip install -r requirements.txt
```

2. Check logs:
```bash
tail -f /var/log/supervisor/backend.out.log
tail -f /var/log/supervisor/backend.err.log
```

### Supervisor Issues

```bash
# Check status
sudo supervisorctl status

# Restart services
sudo supervisorctl restart all

# View logs
sudo supervisorctl tail frontend
sudo supervisorctl tail backend
```

## Deployment

### Production Build

1. Build frontend:
```bash
cd /app/frontend
yarn build
```

2. The build output will be in `/app/frontend/build/`

3. Serve using Nginx or any static file server

### Environment Variables for Production

Update your `.env` files with production values:

```env
# Frontend .env
REACT_APP_BACKEND_URL=https://your-domain.com

# Backend .env
MONGO_URL=mongodb+srv://user:pass@production-cluster.mongodb.net/
DB_NAME=fluxiptv_production
```

## Support

For issues or questions:
- Telegram: @customcloudtv
- Edit contact information in the website footer

## License

Proprietary - Flux IPTV

## Version

1.0.0 - Initial Release

---

**Built for Flux IPTV**
