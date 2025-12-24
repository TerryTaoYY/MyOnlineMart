package com.example.myonlinemart.controller;

import com.example.myonlinemart.dto.AuthResponse;
import com.example.myonlinemart.dto.LoginRequest;
import com.example.myonlinemart.dto.RegisterRequest;
import com.example.myonlinemart.exception.RequestValidationException;
import com.example.myonlinemart.service.AuthService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request,
                                                 BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            throw new RequestValidationException("Validation failed", collectErrors(bindingResult));
        }
        AuthResponse response = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request,
                                              BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            throw new RequestValidationException("Validation failed", collectErrors(bindingResult));
        }
        return ResponseEntity.ok(authService.login(request));
    }

    private List<String> collectErrors(BindingResult bindingResult) {
        return bindingResult.getFieldErrors().stream()
                .map(this::formatFieldError)
                .collect(Collectors.toList());
    }

    private String formatFieldError(FieldError error) {
        return error.getField() + ": " + error.getDefaultMessage();
    }
}
