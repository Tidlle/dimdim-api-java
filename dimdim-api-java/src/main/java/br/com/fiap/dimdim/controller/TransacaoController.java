package br.com.fiap.dimdim.controller;

import br.com.fiap.dimdim.dto.TransacaoRequest;
import br.com.fiap.dimdim.dto.TransacaoResponse;
import br.com.fiap.dimdim.service.TransacaoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/transacoes")
public class TransacaoController {

    private final TransacaoService service;

    public TransacaoController(TransacaoService service) {
        this.service = service;
    }

    // READ - lista completa (opcionalmente filtrada por tipo)
    @GetMapping
    public ResponseEntity<List<TransacaoResponse>> listar(
            @RequestParam(name = "tipo", required = false) String tipo) {

        List<TransacaoResponse> corpo = (tipo == null ? service.listar() : service.listarPorTipo(tipo))
                .stream()
                .map(TransacaoResponse::de)
                .toList();

        return ResponseEntity.ok(corpo);
    }

    // READ - por id
    @GetMapping("/{id}")
    public ResponseEntity<TransacaoResponse> buscar(@PathVariable Long id) {
        return ResponseEntity.ok(TransacaoResponse.de(service.buscarPorId(id)));
    }

    // CREATE
    @PostMapping
    public ResponseEntity<TransacaoResponse> criar(@Valid @RequestBody TransacaoRequest request) {
        TransacaoResponse criada = TransacaoResponse.de(service.criar(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(criada);
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<TransacaoResponse> atualizar(@PathVariable Long id,
                                                       @Valid @RequestBody TransacaoRequest request) {
        return ResponseEntity.ok(TransacaoResponse.de(service.atualizar(id, request)));
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        service.excluir(id);
        return ResponseEntity.noContent().build();
    }
}
