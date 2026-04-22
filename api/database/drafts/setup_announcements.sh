#!/bin/bash

# Quick Setup Script for Dashboard Announcements
# This script will help you set up sample announcements for testing

echo "======================================"
echo "Dashboard Announcements Setup"
echo "======================================"
echo ""

# Check if MySQL is running
if ! pgrep -x "mysqld" > /dev/null; then
    echo "⚠️  MySQL is not running. Please start XAMPP MySQL first."
    exit 1
fi

echo "✅ MySQL is running"
echo ""

# Database configuration
DB_NAME="pelaez_db"
DB_USER="root"
DB_PASS=""

echo "📊 Checking database: $DB_NAME"
echo ""

# Test database connection
mysql -u"$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Database connection successful"
    echo ""

    # Check if announcements table exists
    TABLE_EXISTS=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -se "SHOW TABLES LIKE 'announcements';" 2>/dev/null)

    if [ "$TABLE_EXISTS" = "announcements" ]; then
        echo "✅ Announcements table exists"
        echo ""

        # Count current announcements
        COUNT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -se "SELECT COUNT(*) FROM announcements WHERE is_deleted = 0;" 2>/dev/null)
        echo "📢 Current announcements: $COUNT"
        echo ""

        # Ask if user wants to insert sample data
        read -p "Do you want to insert sample announcements? (y/n): " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo "📝 Inserting sample announcements..."

            mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" < sample_announcements.sql 2>/dev/null

            if [ $? -eq 0 ]; then
                echo "✅ Sample announcements inserted successfully!"

                # Count new total
                NEW_COUNT=$(mysql -u"$DB_USER" -p"$DB_PASS" -D"$DB_NAME" -se "SELECT COUNT(*) FROM announcements WHERE is_deleted = 0;" 2>/dev/null)
                echo "📢 Total announcements now: $NEW_COUNT"
            else
                echo "❌ Error inserting sample data. Check your database configuration."
            fi
        else
            echo "Skipping sample data insertion."
        fi
    else
        echo "❌ Announcements table not found!"
        echo "ℹ️  Please run the pelaez_db-4.sql migration first."
        exit 1
    fi
else
    echo "❌ Cannot connect to database: $DB_NAME"
    echo "ℹ️  Please check your database name and credentials."
    exit 1
fi

echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "🌐 Open your browser to:"
echo "   http://localhost/deped_capstone/dashboard/admin_dashboard.html"
echo ""
echo "📋 API Test:"
echo "   curl http://localhost/deped_capstone/api/announcements/announcements.php?operation=getAllAnnouncements"
echo ""
