package com.example.myonlinemart.service;

import com.example.myonlinemart.entity.UserAccount;
import com.example.myonlinemart.util.SecurityUtils;
import org.springframework.stereotype.Service;

@Service
public class CurrentUserService {

    private final UserService userService;

    public CurrentUserService(UserService userService) {
        this.userService = userService;
    }

    public UserAccount getCurrentUser() {
        String username = SecurityUtils.currentUsername();
        return userService.getByUsername(username);
    }
}
