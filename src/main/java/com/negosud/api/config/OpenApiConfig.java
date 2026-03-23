package com.negosud.api.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI negosudOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("NEGOSUD - API Gestion de Stock")
                        .description("API REST pour la gestion des stocks, commandes clients et fournisseurs de la société NEGOSUD")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("NEGOSUD")
                                .email("contact@negosud.fr")));
    }
}
