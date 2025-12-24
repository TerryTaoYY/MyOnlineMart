package com.example.myonlinemart.service;

import com.example.myonlinemart.dto.RegisterRequest;
import com.example.myonlinemart.entity.Role;
import com.example.myonlinemart.entity.UserAccount;
import com.example.myonlinemart.exception.ResourceConflictException;
import com.example.myonlinemart.exception.ResourceNotFoundException;
import com.example.myonlinemart.repository.UserDao;
import java.time.Instant;
import java.util.Optional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final UserDao userDao;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserDao userDao, PasswordEncoder passwordEncoder) {
        this.userDao = userDao;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public UserAccount registerBuyer(RegisterRequest request) {
        if (userDao.findByUsername(request.username()).isPresent()) {
            throw new ResourceConflictException("Username is already in use.");
        }
        if (userDao.findByEmail(request.email()).isPresent()) {
            throw new ResourceConflictException("Email is already in use.");
        }
        UserAccount user = UserAccount.builder()
                .username(request.username())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .role(Role.BUYER)
                .createdAt(Instant.now())
                .build();
        userDao.save(user);
        return user;
    }

    @Transactional(readOnly = true)
    public Optional<UserAccount> findByUsernameOrEmail(String value) {
        return userDao.findByUsernameOrEmail(value);
    }

    @Transactional(readOnly = true)
    public UserAccount getByUsername(String username) {
        return userDao.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found."));
    }

    @Transactional(readOnly = true)
    public UserAccount getById(Long id) {
        return userDao.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found."));
    }

    @Transactional
    public UserAccount createAdminIfMissing(String username, String email, String rawPassword) {
        Optional<UserAccount> existing = userDao.findByUsername(username);
        if (existing.isPresent()) {
            return existing.get();
        }
        UserAccount admin = UserAccount.builder()
                .username(username)
                .email(email)
                .passwordHash(passwordEncoder.encode(rawPassword))
                .role(Role.ADMIN)
                .createdAt(Instant.now())
                .build();
        userDao.save(admin);
        return admin;
    }
}
