package com.example.myonlinemart.repository;

import com.example.myonlinemart.entity.WatchlistEntry;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Repository;

@Repository
public class WatchlistDao {

    @PersistenceContext
    private EntityManager entityManager;

    public Optional<WatchlistEntry> findByUserAndProduct(Long userId, Long productId) {
        return entityManager.createQuery(
                        "select w from WatchlistEntry w "
                                + "join fetch w.product p "
                                + "where w.user.id = :userId and p.id = :productId", WatchlistEntry.class)
                .setParameter("userId", userId)
                .setParameter("productId", productId)
                .getResultStream()
                .findFirst();
    }

    public List<WatchlistEntry> findInStockByUser(Long userId) {
        return entityManager.createQuery(
                        "select w from WatchlistEntry w "
                                + "join fetch w.product p "
                                + "where w.user.id = :userId and p.stockQuantity > 0 "
                                + "order by p.id", WatchlistEntry.class)
                .setParameter("userId", userId)
                .getResultList();
    }

    public void save(WatchlistEntry entry) {
        entityManager.persist(entry);
    }

    public void delete(WatchlistEntry entry) {
        entityManager.remove(entry);
    }
}
