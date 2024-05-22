#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure Laravel installer is available
if ! command_exists laravel; then
    echo "Laravel installer not found. Installing..."
    composer global require laravel/installer
    export PATH="$HOME/.composer/vendor/bin:$PATH"
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

# Check if an app name was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <app-name>"
    exit 1
fi

APP_NAME=$1

# Create new Laravel application
echo "Creating new Laravel application named $APP_NAME..."
laravel new $APP_NAME
cd $APP_NAME

# Install Laravel UI for scaffolding
composer require laravel/ui
php artisan ui vue --auth
npm install && npm run dev

# Generate CRUD for a sample resource (e.g., Post)
RESOURCE_NAME=Post
php artisan make:model $RESOURCE_NAME -mcr

# Update migration file
MIGRATION_FILE=$(ls database/migrations/*_create_${RESOURCE_NAME,,}s_table.php)
cat <<EOT > $MIGRATION_FILE
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class Create${RESOURCE_NAME}sTable extends Migration
{
    public function up()
    {
        Schema::create('${RESOURCE_NAME,,}s', function (Blueprint \$table) {
            \$table->id();
            \$table->string('title');
            \$table->text('content');
            \$table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('${RESOURCE_NAME,,}s');
    }
}
EOT

# Run migrations
php artisan migrate

# Add resource routes
sed -i '' "/Route::get('\/',/a Route::resource('${RESOURCE_NAME,,}s', ${RESOURCE_NAME}Controller::class);" routes/web.php

# Update controller with basic CRUD methods
cat <<EOT > app/Http/Controllers/${RESOURCE_NAME}Controller.php
<?php

namespace App\Http\Controllers;

use App\Models\\${RESOURCE_NAME};
use Illuminate\Http\Request;

class ${RESOURCE_NAME}Controller extends Controller
{
    public function index()
    {
        \$${RESOURCE_NAME,,}s = ${RESOURCE_NAME}::all();
        return view('${RESOURCE_NAME,,}s.index', compact('${RESOURCE_NAME,,}s'));
    }

    public function create()
    {
        return view('${RESOURCE_NAME,,}s.create');
    }

    public function store(Request \$request)
    {
        ${RESOURCE_NAME}::create(\$request->all());
        return redirect()->route('${RESOURCE_NAME,,}s.index');
    }

    public function show(${RESOURCE_NAME} \${RESOURCE_NAME,,})
    {
        return view('${RESOURCE_NAME,,}s.show', compact('${RESOURCE_NAME,,}'));
    }

    public function edit(${RESOURCE_NAME} \${RESOURCE_NAME,,})
    {
        return view('${RESOURCE_NAME,,}s.edit', compact('${RESOURCE_NAME,,}'));
    }

    public function update(Request \$request, ${RESOURCE_NAME} \${RESOURCE_NAME,,})
    {
        \${RESOURCE_NAME,,}->update(\$request->all());
        return redirect()->route('${RESOURCE_NAME,,}s.index');
    }

    public function destroy(${RESOURCE_NAME} \${RESOURCE_NAME,,})
    {
        \${RESOURCE_NAME,,}->delete();
        return redirect()->route('${RESOURCE_NAME,,}s.index');
    }
}
EOT

# Create basic views
mkdir -p resources/views/${RESOURCE_NAME,,}s
cat <<EOT > resources/views/${RESOURCE_NAME,,}s/index.blade.php
@extends('layouts.app')

@section('content')
    <div class="container">
        <h1>${RESOURCE_NAME}s</h1>
        <a href="{{ route('${RESOURCE_NAME,,}s.create') }}" class="btn btn-primary">Create ${RESOURCE_NAME}</a>
        <ul>
            @foreach(\$${RESOURCE_NAME,,}s as \${RESOURCE_NAME,,})
                <li>
                    <a href="{{ route('${RESOURCE_NAME,,}s.show', \${RESOURCE_NAME,,}->id) }}">{{ \${RESOURCE_NAME,,}->title }}</a>
                    <a href="{{ route('${RESOURCE_NAME,,}s.edit', \${RESOURCE_NAME,,}->id) }}">Edit</a>
                    <form action="{{ route('${RESOURCE_NAME,,}s.destroy', \${RESOURCE_NAME,,}->id) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger">Delete</button>
                    </form>
                </li>
            @endforeach
        </ul>
    </div>
@endsection
EOT

# Add other necessary view files (create, edit, show) similarly...

echo "Laravel CRUD application for ${RESOURCE_NAME} created successfully."

