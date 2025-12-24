package com.example.myonlinemart.repository;

import com.example.myonlinemart.entity.Product;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Repository;

@Repository
public class ProductDao {

    @PersistenceContext
    private EntityManager entityManager;

    public List<Product> findInStock() {
        return entityManager.createQuery(
                        "from Product p where p.stockQuantity > 0 order by p.id", Product.class)
                .getResultList();
    }

    public List<Product> findAll() {
        return entityManager.createQuery("from Product p order by p.id", Product.class)
                .getResultList();
    }

    public Optional<Product> findById(Long id) {
        return Optional.ofNullable(entityManager.find(Product.class, id));
    }

    public void save(Product product) {
        entityManager.persist(product);
    }

    public Product merge(Product product) {
        return entityManager.merge(product);
    }
}
