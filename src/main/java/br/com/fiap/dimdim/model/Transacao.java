package br.com.fiap.dimdim.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Mapeamento da tabela TRANSACOES.
 * O DDL fica em db/init/01_ddl.sql - a aplicacao nao cria nem altera schema.
 */
@Entity
@Table(name = "TRANSACOES")
public class Transacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Long id;

    @Column(name = "DESCRICAO", nullable = false, length = 200)
    private String descricao;

    @Column(name = "VALOR", nullable = false, precision = 12, scale = 2)
    private BigDecimal valor;

    @Column(name = "DATA_TRANSACAO", nullable = false)
    private LocalDateTime dataTransacao;

    @Column(name = "TIPO", nullable = false, length = 20)
    private String tipo;

    public Transacao() {
    }

    public Transacao(String descricao, BigDecimal valor, LocalDateTime dataTransacao, String tipo) {
        this.descricao = descricao;
        this.valor = valor;
        this.dataTransacao = dataTransacao;
        this.tipo = tipo;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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
