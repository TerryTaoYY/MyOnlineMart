package com.example.myonlinemart.config;

import com.example.myonlinemart.service.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserService userService;
    private final String adminUsername;
    private final String adminEmail;
    private final String adminPassword;

    public DataInitializer(UserService userService,
                           @Value("${app.admin.username:admin}") String adminUsername,
                           @Value("${app.admin.email:admin@myonlinemart.local}") String adminEmail,
                           @Value("${app.admin.password:admin12345}") String adminPassword) {
        this.userService = userService;
        this.adminUsername = adminUsername;
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
    }

    @Override
    public void run(String... args) {
        userService.createAdminIfMissing(adminUsername, adminEmail, adminPassword);
    }
}
