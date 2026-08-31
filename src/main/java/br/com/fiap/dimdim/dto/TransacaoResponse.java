package br.com.fiap.dimdim.dto;

import br.com.fiap.dimdim.model.Transacao;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TransacaoResponse {

    private Long id;
    private String descricao;
    private BigDecimal valor;
    private LocalDateTime dataTransacao;
    private String tipo;

    public static TransacaoResponse de(Transacao transacao) {
        TransacaoResponse response = new TransacaoResponse();
        response.id = transacao.getId();
        response.descricao = transacao.getDescricao();
        response.valor = transacao.getValor();
        response.dataTransacao = transacao.getDataTransacao();
        response.tipo = transacao.getTipo();
        return response;
    }

    public Long getId() {
        return id;
    }

    public String getDescricao() {
        return descricao;
    }

    public BigDecimal getValor() {
        return valor;
    }

    public LocalDateTime getDataTransacao() {
        return dataTransacao;
    }

    public String getTipo() {
        return tipo;
    }
}
