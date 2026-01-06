#!/bin/bash

# Finite App Setup Script
# This script helps set up the Xcode project

echo "🕐 Finite App Setup"
echo "==================="
echo ""

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "📦 Installing XcodeGen..."
    brew install xcodegen
else
    echo "✅ XcodeGen already installed"
fi

# Generate Xcode project
echo ""
echo "🔨 Generating Xcode project..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo "✅ Xcode project generated successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Open Finite.xcodeproj in Xcode"
    echo "  2. Update SupabaseService.swift with your Supabase credentials"
    echo "  3. Configure your Apple Developer signing"
    echo "  4. Run the app!"
    echo ""
    echo "🗄️  Don't forget to run the SQL schema in Supabase:"
    echo "  supabase/schema.sql"
    echo ""
    
    # Ask to open Xcode
    read -p "Would you like to open the project in Xcode now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open Finite.xcodeproj
    fi
else
    echo "❌ Failed to generate Xcode project"
    echo ""
    echo "Alternative: Create project manually in Xcode"
    echo "  1. File > New > Project > iOS App"
    echo "  2. Name: Finite, Interface: SwiftUI, Language: Swift"
    echo "  3. Add Supabase package: https://github.com/supabase/supabase-swift"
    echo "  4. Copy all Swift files into the project"
    echo "  5. Add Widget Extension target"
fi
