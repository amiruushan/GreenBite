package com.greenbite.backend.repository;

import com.greenbite.backend.model.CouponManagement;
import com.greenbite.backend.model.User;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CouponManagementRepository extends CrudRepository<CouponManagement, Long> {
    List<CouponManagement> findByUser(User user);
    Optional<CouponManagement> findByCouponCode(String couponCode);
}
