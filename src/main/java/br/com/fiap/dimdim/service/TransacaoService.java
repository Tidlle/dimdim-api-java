package br.com.fiap.dimdim.service;

import br.com.fiap.dimdim.dto.TransacaoRequest;
import br.com.fiap.dimdim.exception.RecursoNaoEncontradoException;
import br.com.fiap.dimdim.model.Transacao;
import br.com.fiap.dimdim.repository.TransacaoRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class TransacaoService {

    private final TransacaoRepository repository;

    public TransacaoService(TransacaoRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public List<Transacao> listar() {
        return repository.findAll(Sort.by(Sort.Direction.ASC, "id"));
    }

    @Transactional(readOnly = true)
    public List<Transacao> listarPorTipo(String tipo) {
        return repository.findByTipoOrderByIdDesc(tipo.toUpperCase());
    }

    @Transactional(readOnly = true)
    public Transacao buscarPorId(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Transacao com id " + id + " nao encontrada"));
    }

    @Transactional
    public Transacao criar(TransacaoRequest request) {
        Transacao transacao = new Transacao();
        aplicar(transacao, request);
        return repository.save(transacao);
    }

    @Transactional
    public Transacao atualizar(Long id, TransacaoRequest request) {
        Transacao transacao = buscarPorId(id);
        aplicar(transacao, request);
        return repository.save(transacao);
    }

    @Transactional
    public void excluir(Long id) {
        Transacao transacao = buscarPorId(id);
        repository.delete(transacao);
    }

    private void aplicar(Transacao transacao, TransacaoRequest request) {
        transacao.setDescricao(request.getDescricao());
        transacao.setValor(request.getValor());
        transacao.setTipo(request.getTipo().toUpperCase());
        transacao.setDataTransacao(
                request.getDataTransacao() != null ? request.getDataTransacao() : LocalDateTime.now());
    }
}
