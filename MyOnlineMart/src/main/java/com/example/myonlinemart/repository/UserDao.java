package com.example.myonlinemart.repository;

import com.example.myonlinemart.entity.UserAccount;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.Optional;
import org.springframework.stereotype.Repository;

@Repository
public class UserDao {

    @PersistenceContext
    private EntityManager entityManager;

    public Optional<UserAccount> findByUsername(String username) {
        return entityManager.createQuery(
                        "from UserAccount u where u.username = :username", UserAccount.class)
                .setParameter("username", username)
                .getResultStream()
                .findFirst();
    }

    public Optional<UserAccount> findByEmail(String email) {
        return entityManager.createQuery(
                        "from UserAccount u where u.email = :email", UserAccount.class)
                .setParameter("email", email)
                .getResultStream()
                .findFirst();
    }

    public Optional<UserAccount> findByUsernameOrEmail(String usernameOrEmail) {
        return entityManager.createQuery(
                        "from UserAccount u where u.username = :value or u.email = :value", UserAccount.class)
                .setParameter("value", usernameOrEmail)
                .getResultStream()
                .findFirst();
    }

    public Optional<UserAccount> findById(Long id) {
        return Optional.ofNullable(entityManager.find(UserAccount.class, id));
    }

    public void save(UserAccount userAccount) {
        entityManager.persist(userAccount);
    }

    public UserAccount merge(UserAccount userAccount) {
        return entityManager.merge(userAccount);
    }
}
