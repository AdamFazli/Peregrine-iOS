# 🌳 Branch Management Guide

## Your Branches Explained

You now have **two separate branches** for different purposes:

### 1. `feature/testing` - Development & Testing
**Use this when:** You want to test and develop features

**Contains:**
- ✅ All animations and features
- ✅ MockNetworkManager (unlimited API testing)
- ✅ Debug flags (useMockData, logAPIRequests)
- ✅ Testing documentation (QUICK_FIX.md, HOW_TO_TEST.md, etc.)
- ✅ FEATURES.md with complete animation docs

**Perfect for:**
- Testing without API limits
- Rapid development
- Recording demo videos
- Debugging issues

---

### 2. `feature/submission` - Clean Production Code
**Use this when:** You want to push to GitHub or submit your assignment

**Contains:**
- ✅ All animations and features
- ✅ Daily/weekly chart functionality
- ✅ Pull-to-refresh
- ✅ All unit tests
- ❌ NO mock data code
- ❌ NO debug flags
- ❌ NO testing documentation

**Perfect for:**
- GitHub submissions
- Assignment turnover
- Professional portfolio
- Production deployment

---

## 🔄 How to Switch Branches

### Switch to Testing Branch (for development)
```bash
cd "/Users/adamfazli/workspace/Stock Screener App"
git checkout feature/testing
```

Then rebuild in Xcode (`⌘R`)

✨ **Now you can test unlimited with mock data!**

---

### Switch to Submission Branch (for pushing to GitHub)
```bash
cd "/Users/adamfazli/workspace/Stock Screener App"
git checkout feature/submission
```

Then rebuild in Xcode (`⌘R`)

🚀 **Now you have clean production code!**

---

## 📤 Pushing to GitHub

### For Submission Branch (Clean Code)
```bash
# Make sure you're on submission branch
git checkout feature/submission

# Push to GitHub
git push -u origin feature/submission
```

### For Testing Branch (Keep Private or Push to Different Branch)
```bash
# Make sure you're on testing branch
git checkout feature/testing

# Option 1: Don't push (keep local only)
# Option 2: Push to a dev branch
git push -u origin feature/testing
```

---

## ✅ Current Status

| Branch | Status | Last Commit |
|--------|--------|-------------|
| `feature/testing` | ✅ Committed | "feat: add animations, daily/weekly charts, and testing infrastructure" |
| `feature/submission` | ✅ Committed | "feat: add smooth animations and daily/weekly charts" |

---

## 🎯 Workflow Examples

### Example 1: Testing New Feature
```bash
# Switch to testing branch
git checkout feature/testing

# Open in Xcode, enable mock data, test freely
# Make changes...

# Commit changes
git add .
git commit -m "feat: add new feature"
```

### Example 2: Preparing for Submission
```bash
# Switch to submission branch
git checkout feature/submission

# Cherry-pick the clean changes (without mock/debug)
# Or manually apply the feature code

# Commit
git add .
git commit -m "feat: add production-ready feature"

# Push to GitHub
git push origin feature/submission
```

### Example 3: Recording Demo Video
```bash
# Switch to testing branch (has mock data)
git checkout feature/testing

# Rebuild in Xcode (⌘R)
# Record video with no API limits!
```

### Example 4: Final Submission
```bash
# Switch to submission branch
git checkout feature/submission

# Verify it's clean (no mock/debug files)
git status

# Push to GitHub
git push origin feature/submission

# Create PR or submit link
```

---

## 🔍 Quick Check: Which Branch Am I On?

```bash
git branch --show-current
```

Or in Xcode: Look at the bottom right corner

---

## 📊 Compare Branches

### See what's different:
```bash
# Compare file differences
git diff feature/testing feature/submission

# List different files
git diff --name-only feature/testing feature/submission
```

### Key Differences:
```
feature/testing HAS:
+ MockNetworkManager.swift
+ QUICK_FIX.md
+ HOW_TO_TEST.md
+ TESTING_GUIDE.md
+ ENABLE_TESTING_MODE.md
+ Debug flags in Constants.swift

feature/submission DOES NOT HAVE:
- MockNetworkManager.swift
- Testing documentation
- Debug flags
```

---

## 💡 Pro Tips

1. **Always check your branch** before pushing:
   ```bash
   git branch --show-current
   ```

2. **Keep branches in sync** for features:
   - Develop in `feature/testing`
   - Clean and copy to `feature/submission`

3. **For assignment submission**:
   - Use `feature/submission` branch
   - Verify no mock/debug code exists
   - Push to GitHub

4. **For demo videos**:
   - Use `feature/testing` branch
   - Enable mock data
   - Record without API limits

5. **Never lose work**:
   - Both branches are saved
   - Can switch anytime
   - All commits preserved

---

## 🆘 Troubleshooting

### Problem: Can't switch branches (uncommitted changes)
```bash
# Save current work temporarily
git stash

# Switch branch
git checkout feature/submission

# To restore later:
git checkout feature/testing
git stash pop
```

### Problem: Forgot which branch I'm on
```bash
# Show current branch
git branch --show-current

# Or show all branches
git branch -v
```

### Problem: Want to merge branches
```bash
# Generally DON'T merge these branches
# They serve different purposes
# Instead, cherry-pick specific commits or manually copy features
```

---

## 📝 Summary

- ✅ **2 branches created and committed**
- ✅ `feature/testing` - Full development setup with mock data
- ✅ `feature/submission` - Clean production code
- ✅ Easy to switch between them
- ✅ All work is saved and committed
- ✅ Ready to push either branch anytime

**For assignment submission:**
```bash
git checkout feature/submission
git push -u origin feature/submission
```

**For testing and development:**
```bash
git checkout feature/testing
# Test freely with mock data!
```

---

**You're all set! 🎉**
