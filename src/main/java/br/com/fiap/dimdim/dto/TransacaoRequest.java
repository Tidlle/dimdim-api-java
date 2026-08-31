package br.com.fiap.dimdim.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Payload de entrada para POST e PUT.
 * dataTransacao e opcional: se vier nula, a API usa o instante atual.
 */
public class TransacaoRequest {

    @NotBlank(message = "descricao e obrigatoria")
    @Size(max = 200, message = "descricao deve ter no maximo 200 caracteres")
    private String descricao;

    @NotNull(message = "valor e obrigatorio")
    private BigDecimal valor;

    private LocalDateTime dataTransacao;

    @NotBlank(message = "tipo e obrigatorio")
    @Pattern(regexp = "CREDITO|DEBITO", message = "tipo deve ser CREDITO ou DEBITO")
    private String tipo;

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public BigDecimal getValor() {
        return valor;
    }

    public void setValor(BigDecimal valor) {
        this.valor = valor;
    }

    public LocalDateTime getDataTransacao() {
        return dataTransacao;
    }

    public void setDataTransacao(LocalDateTime dataTransacao) {
        this.dataTransacao = dataTransacao;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
}
