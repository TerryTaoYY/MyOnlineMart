package com.example.myonlinemart.exception;

public class NotEnoughInventoryException extends RuntimeException {
    public NotEnoughInventoryException(String message) {
        super(message);
    }
}
