package com.greenbite.backend.service;

import com.greenbite.backend.model.Deal;
import com.greenbite.backend.repository.DealRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DealService {
    private final DealRepository dealRepository;

    public DealService(DealRepository dealRepository) {
        this.dealRepository = dealRepository;
    }

    public List<Deal> getAllDeals() {
        return (List<Deal>) dealRepository.findAll();
    }
}