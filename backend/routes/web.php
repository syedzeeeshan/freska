<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'service' => 'Freska Logistics API',
        'status' => 'operational',
        'version' => '1.0.0',
    ]);
});
