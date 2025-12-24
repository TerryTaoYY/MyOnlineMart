package com.example.myonlinemart.aop;

import com.example.myonlinemart.dto.ErrorResponse;
import com.example.myonlinemart.exception.*;
import jakarta.validation.ConstraintViolationException;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.time.Instant;
import java.util.List;
import java.util.stream.Collectors;

@Aspect
@Component
public class ControllerExceptionAspect {

    @Around("within(@org.springframework.web.bind.annotation.RestController *)")
    public Object wrapExceptions(ProceedingJoinPoint joinPoint) throws Throwable {
        try {
            return joinPoint.proceed();
        } catch (RequestValidationException ex) {
            return build(HttpStatus.BAD_REQUEST, "ValidationError", ex.getMessage(), ex.getErrors());
        } catch (InvalidCredentialsException ex) {
            return build(HttpStatus.UNAUTHORIZED, "InvalidCredentials", ex.getMessage(), null);
        } catch (UnauthorizedAccessException ex) {
            return build(HttpStatus.FORBIDDEN, "Forbidden", ex.getMessage(), null);
        } catch (ResourceNotFoundException ex) {
            return build(HttpStatus.NOT_FOUND, "NotFound", ex.getMessage(), null);
        } catch (ResourceConflictException ex) {
            return build(HttpStatus.CONFLICT, "Conflict", ex.getMessage(), null);
        } catch (NotEnoughInventoryException ex) {
            return build(HttpStatus.CONFLICT, "NotEnoughInventory", ex.getMessage(), null);
        } catch (MethodArgumentNotValidException ex) {
            List<String> details = ex.getBindingResult().getFieldErrors().stream()
                    .map(this::formatFieldError)
                    .collect(Collectors.toList());
            return build(HttpStatus.BAD_REQUEST, "ValidationError", "Validation failed", details);
        } catch (ConstraintViolationException ex) {
            List<String> details = ex.getConstraintViolations().stream()
                    .map(violation -> violation.getPropertyPath() + ": " + violation.getMessage())
                    .collect(Collectors.toList());
            return build(HttpStatus.BAD_REQUEST, "ValidationError", "Validation failed", details);
        } catch (IllegalArgumentException ex) {
            return build(HttpStatus.BAD_REQUEST, "BadRequest", ex.getMessage(), null);
        } catch (IllegalStateException ex) {
            return build(HttpStatus.CONFLICT, "Conflict", ex.getMessage(), null);
        } catch (Exception ex) {
            return build(HttpStatus.INTERNAL_SERVER_ERROR, "ServerError", "Unexpected error occurred", List.of(ex.getMessage()));
        }
    }

    private String formatFieldError(FieldError error) {
        return error.getField() + ": " + error.getDefaultMessage();
    }

    private ResponseEntity<ErrorResponse> build(HttpStatus status, String error, String message, List<String> details) {
        ErrorResponse response = new ErrorResponse(error, message, details, Instant.now());
        return ResponseEntity.status(status).body(response);
    }
}
