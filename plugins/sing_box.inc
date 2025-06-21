<?php

/*
 * Copyright (C) 2024  https://pfchina.org/
 * All rights reserved.
 *
 */


function sing_box_services()
{
    global $config;

    $services = array();

    $services[] = array(
        'description' => gettext('Sing-Box'),
        'configd' => array(
            'restart' => array('sing-box restart'),
            'start' => array('sing-box start'),
            'stop' => array('sing-box stop'),
        ),
        'name' => 'sing-box',
        'pidfile' => '/var/run/sing-box.pid',
        'enabled' => true,
        'rcfile' => '/usr/local/etc/rc.d/sing-box',
    );

    return $services;
}