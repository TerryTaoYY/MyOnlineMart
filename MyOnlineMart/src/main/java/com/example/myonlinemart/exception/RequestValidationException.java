package com.example.myonlinemart.exception;

import java.util.List;

public class RequestValidationException extends RuntimeException {
    private final List<String> errors;

    public RequestValidationException(String message, List<String> errors) {
        super(message);
        this.errors = errors;
    }

    public List<String> getErrors() {
        return errors;
    }
}
