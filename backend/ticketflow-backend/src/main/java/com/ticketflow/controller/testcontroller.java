package com.ticketflow.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class testcontroller {

    @GetMapping("/api/test")
    public String test() {
        return "TicketFlow Backend is running!";
    }
}