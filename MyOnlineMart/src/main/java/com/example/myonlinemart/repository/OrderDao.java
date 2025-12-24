package com.example.myonlinemart.repository;

import com.example.myonlinemart.entity.Order;
import com.example.myonlinemart.entity.OrderStatus;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Repository;

@Repository
public class OrderDao {

    @PersistenceContext
    private EntityManager entityManager;

    public void save(Order order) {
        entityManager.persist(order);
    }

    public Optional<Order> findById(Long id) {
        return Optional.ofNullable(entityManager.find(Order.class, id));
    }

    public Optional<Order> findWithItems(Long id) {
        return entityManager.createQuery(
                        "select distinct o from Order o "
                                + "left join fetch o.items oi "
                                + "left join fetch oi.product "
                                + "left join fetch o.buyer "
                                + "where o.id = :id", Order.class)
                .setParameter("id", id)
                .getResultStream()
                .findFirst();
    }

    public List<Order> findByBuyerId(Long buyerId) {
        CriteriaBuilder builder = entityManager.getCriteriaBuilder();
        CriteriaQuery<Order> query = builder.createQuery(Order.class);
        Root<Order> root = query.from(Order.class);
        query.select(root)
                .where(builder.equal(root.get("buyer").get("id"), buyerId))
                .orderBy(builder.desc(root.get("placedAt")));
        TypedQuery<Order> typedQuery = entityManager.createQuery(query);
        return typedQuery.getResultList();
    }

    public List<Order> findAllPaged(int offset, int limit) {
        return entityManager.createQuery(
                        "select o from Order o join fetch o.buyer b order by o.placedAt desc", Order.class)
                .setFirstResult(offset)
                .setMaxResults(limit)
                .getResultList();
    }

    public List<Object[]> findTopPurchasedItems(Long buyerId, int limit) {
        return entityManager.createQuery(
                        "select oi.product.id, oi.product.description, sum(oi.quantity) "
                                + "from OrderItem oi join oi.order o "
                                + "where o.buyer.id = :buyerId and o.status <> :status "
                                + "group by oi.product.id, oi.product.description "
                                + "order by sum(oi.quantity) desc, oi.product.id asc", Object[].class)
                .setParameter("buyerId", buyerId)
                .setParameter("status", OrderStatus.CANCELED)
                .setMaxResults(limit)
                .getResultList();
    }

    public List<Object[]> findRecentPurchasedItems(Long buyerId, int limit) {
        return entityManager.createQuery(
                        "select oi.product.id, oi.product.description, max(o.placedAt) "
                                + "from OrderItem oi join oi.order o "
                                + "where o.buyer.id = :buyerId and o.status <> :status "
                                + "group by oi.product.id, oi.product.description "
                                + "order by max(o.placedAt) desc, oi.product.id asc", Object[].class)
                .setParameter("buyerId", buyerId)
                .setParameter("status", OrderStatus.CANCELED)
                .setMaxResults(limit)
                .getResultList();
    }

    public Optional<Object[]> findMostProfitableProduct() {
        return entityManager.createQuery(
                        "select oi.product.id, oi.product.description, "
                                + "sum(oi.unitRetailPrice * oi.quantity) - sum(oi.unitWholesalePrice * oi.quantity) "
                                + "from OrderItem oi join oi.order o "
                                + "where o.status = :status "
                                + "group by oi.product.id, oi.product.description "
                                + "order by sum(oi.unitRetailPrice * oi.quantity) - sum(oi.unitWholesalePrice * oi.quantity) desc, "
                                + "oi.product.id asc", Object[].class)
                .setParameter("status", OrderStatus.COMPLETED)
                .setMaxResults(1)
                .getResultStream()
                .findFirst();
    }

    public List<Object[]> findTopPopularProducts(int limit) {
        return entityManager.createQuery(
                        "select oi.product.id, oi.product.description, sum(oi.quantity) "
                                + "from OrderItem oi join oi.order o "
                                + "where o.status = :status "
                                + "group by oi.product.id, oi.product.description "
                                + "order by sum(oi.quantity) desc, oi.product.id asc", Object[].class)
                .setParameter("status", OrderStatus.COMPLETED)
                .setMaxResults(limit)
                .getResultList();
    }

    public Long findTotalItemsSold() {
        return entityManager.createQuery(
                        "select coalesce(sum(oi.quantity), 0) from OrderItem oi join oi.order o "
                                + "where o.status = :status", Long.class)
                .setParameter("status", OrderStatus.COMPLETED)
                .getSingleResult();
    }
}
