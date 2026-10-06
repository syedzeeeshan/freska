<?php

use Illuminate\Support\Facades\Schedule;

// Register scheduled background tasks
Schedule::command('model:prune')->daily();
