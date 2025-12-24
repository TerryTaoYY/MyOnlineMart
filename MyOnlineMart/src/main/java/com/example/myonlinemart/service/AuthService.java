package com.example.myonlinemart.service;

import com.example.myonlinemart.dto.AuthResponse;
import com.example.myonlinemart.dto.LoginRequest;
import com.example.myonlinemart.dto.RegisterRequest;
import com.example.myonlinemart.entity.UserAccount;
import com.example.myonlinemart.exception.InvalidCredentialsException;
import com.example.myonlinemart.security.JwtTokenService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;

    public AuthService(UserService userService, PasswordEncoder passwordEncoder, JwtTokenService jwtTokenService) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenService = jwtTokenService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        UserAccount user = userService.registerBuyer(request);
        String token = jwtTokenService.generateToken(user);
        return new AuthResponse(token, user.getRole().name(), user.getUsername(), user.getId());
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        UserAccount user = userService.findByUsernameOrEmail(request.usernameOrEmail())
                .orElseThrow(() -> new InvalidCredentialsException("Incorrect credentials, please try again."));
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new InvalidCredentialsException("Incorrect credentials, please try again.");
        }
        String token = jwtTokenService.generateToken(user);
        return new AuthResponse(token, user.getRole().name(), user.getUsername(), user.getId());
    }
}
