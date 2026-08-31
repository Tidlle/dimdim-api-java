package br.com.fiap.dimdim.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Endpoint simples usado no video para provar que a API respondeu
 * antes mesmo de qualquer operacao de CRUD.
 */
@RestController
public class HealthController {

    @GetMapping("/")
    public Map<String, String> raiz() {
        return Map.of(
                "aplicacao", "DimDim API - Transacoes",
                "status", "online",
                "documentacao", "/api/transacoes");
    }
}
