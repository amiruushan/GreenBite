package com.greenbite.backend.dto;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FoodItemDTO {
    private Long id;
    private String name;
    private String restaurant;
    private String description;
    private Double price;
    private Integer quantity;
    private Long shopId;
    private String photo;

    @JsonDeserialize(using = TagsDeserializer.class) // Custom deserializer for tags
    private List<String> tags;

    private String category;

    // Custom deserializer for tags
    public static class TagsDeserializer extends JsonDeserializer<List<String>> {
        @Override
        public List<String> deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
            String tagsString = p.getValueAsString(); // Get the value as a string
            if (tagsString == null || tagsString.isEmpty()) {
                return List.of(); // Return an empty list if the string is null or empty
            }
            return Arrays.asList(tagsString.split(",")); // Split the string by commas
        }
    }
}