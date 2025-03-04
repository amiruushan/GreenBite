package com.greenbite.backend.repository;

import com.greenbite.backend.model.Deal;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DealRepository extends CrudRepository<Deal, Long> {
}