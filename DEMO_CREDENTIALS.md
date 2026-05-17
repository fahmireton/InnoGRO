# InnoGro Demo Credentials & Testing Guide

## 🎯 Ready to Test!

Your app is now running with **local authentication** — no Firebase setup needed!

## 📧 Test Credentials

### Demo Account (Auto-created)
```
Email:    farmer@innogro.my
Password: demo123
```

**Name:** Ahmad Rahman  
**Farm:** Sawah Pak Ahmad  
**Location:** Sekinchan, Selangor  

### How to Use Demo Account
1. On the login screen, tap the blue "Demo Account" banner
2. Credentials will auto-fill
3. Click "Sign In"

## 🆕 Create New Account

### Registration Form Fields
- **Full Name:** Your name (e.g., "Siti Aishah")
- **Email:** Any email (e.g., "farmer2@example.com")
- **Password:** Min. 6 characters
- **Farm Name:** Your farm name (e.g., "Kebun Padi Siti")
- **State:** Select from dropdown (13 states + 3 Federal Territories)
- **District:** Auto-populates based on selected state
- **GPS Location:** Optional - tap "Capture GPS Location" button

### Example Registration Data
```
Name:      Siti Aishah
Email:     siti@kebun.my
Password:  kebun123
Farm Name: Kebun Padi Siti
State:     Kedah
District:  Kota Setar
```

## 🗺️ Malaysian States & Districts

All states included with real districts:
- **Kedah** (12 districts) - Major paddy farming area
- **Perlis** (3 districts) - Major paddy farming area
- **Selangor** (9 districts) - Includes Sekinchan
- **Perak** (11 districts) - Includes Bagan Datuk
- **Kelantan, Terengganu** - East coast paddy areas
- And all other states...

## 🔐 How Authentication Works

### Local Storage (No Firebase)
- All accounts stored in browser's **SharedPreferences**
- Passwords stored in plain text (demo only!)
- Data persists across browser sessions
- No internet connection needed for auth

### Auth Flow
1. **First Time:** Splash → Onboarding → Login/Register
2. **Returning User:** Splash → Home (auto-login)
3. **Sign Out:** Profile → Sign Out button

## ✅ What Works Without Firebase

- ✅ User registration with farm details
- ✅ Email/password login
- ✅ State & district selection (Malaysian locations)
- ✅ GPS location capture
- ✅ Profile display with user data
- ✅ Auto-login on return visits
- ✅ Sign out functionality
- ✅ AI disease detection (Gemini API)
- ✅ Weather data (OpenWeatherMap API)
- ✅ All UI features and animations

## 🎨 UI Features Included

- **Animated greeting** showing real user name
- **State/District dropdowns** with all Malaysian locations
- **GPS location button** with success feedback
- **Demo credentials banner** on login screen
- **Professional form design** with validation
- **Loading states** for async operations

## 📱 Testing Checklist

- [ ] Tap "Demo Account" banner on login
- [ ] Sign in with demo credentials
- [ ] See personalized greeting on home screen
- [ ] Check profile shows correct user data
- [ ] Sign out successfully
- [ ] Create new account with state/district selection
- [ ] Test GPS location capture (optional)
- [ ] Test AI scan feature
- [ ] Test weather display

## 🚀 For Your Hackathon

This setup is perfect for demos because:
1. **No backend configuration** needed
2. **Works offline** for authentication
3. **Real user experience** with personalized data
4. **Professional UI** with Malaysian locations
5. **All features functional** (AI, weather, etc.)

## 🔄 Reset Everything

To clear all test accounts and start fresh:
1. Open Browser DevTools (F12)
2. Go to "Application" tab
3. Find "Local Storage"
4. Delete all InnoGro entries

Or just use Incognito/Private mode for a fresh start!

---

**Ready to demo!** 🎉 Your judges will see a fully functional app with real authentication flow and Malaysian-specific location data.
