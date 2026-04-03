package com.haraay.ywarchitects.config;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.json.Jackson2ObjectMapperBuilder;

@Configuration
public class JacksonConfig {

    @Bean
    public ObjectMapper objectMapper(Jackson2ObjectMapperBuilder builder) {
        ObjectMapper objectMapper = builder.createXmlMapper(false).build();
        
        // Explicitly register JavaTimeModule (even if builder does it)
        objectMapper.registerModule(new JavaTimeModule());
        
        // Additional configuration to ensure proper LocalDateTime handling
        objectMapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
        objectMapper.configure(DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE, false);
        
        return objectMapper;
    }
}
//@Configuration
//public class JacksonConfig {
//    
//    @Bean
//    public ObjectMapper objectMapper() {
//        ObjectMapper mapper = new ObjectMapper();
//        
//        // Register JavaTimeModule to handle Java 8 date/time types
//        mapper.registerModule(new JavaTimeModule());
//        
//        // Optional: Configure serialization features
//        mapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
//        mapper.configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, false);
//        
//        // Optional: Configure deserialization features
//        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
//        
//        return mapper;
//    }
//    
//   
//
//       
//    
//}
