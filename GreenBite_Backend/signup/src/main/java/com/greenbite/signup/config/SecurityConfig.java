package com.greenbite.signup.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf().disable()  // Disable CSRF for testing, but enable it in production
                .authorizeHttpRequests()
                .requestMatchers(HttpMethod.POST, "/api/auth/signup").permitAll()  // Allow signup without authentication
                .anyRequest().authenticated()  // Require authentication for other requests
                .and()
                .formLogin().disable()  // Disable form login
                .httpBasic().disable();  // Disable basic authentication

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}




