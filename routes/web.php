<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

// Health check route for debugging
Route::get('/health', function () {
    return response()->json([
        'status' => 'OK',
        'timestamp' => now(),
        'environment' => app()->environment(),
        'database' => 'Connected'
    ]);
});

// Simple test route without Inertia
Route::get('/test', function () {
    return '<h1>Laravel is working!</h1><p>Database: ' . DB::connection()->getDatabaseName() . '</p>';
});

Route::get('/', fn () =>
    // Temporary fix - return simple HTML instead of Inertia
    '<h1>🎉 Laravel is Working!</h1>
     <p>✅ Server: Running</p>
     <p>✅ Database: ' . DB::connection()->getDatabaseName() . '</p>
     <p>✅ Environment: ' . app()->environment() . '</p>
     <p><a href="/health">Health Check</a> | <a href="/test">Test Page</a></p>'
    // return Inertia::render('welcome');
)->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', function () {
        return Inertia::render('dashboard');
    })->name('dashboard');
});

require __DIR__.'/settings.php';
require __DIR__.'/auth.php';
