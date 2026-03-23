package com.negosud.api.mapper;

import com.negosud.api.dto.request.ArticleRequestDto;
import com.negosud.api.dto.response.ArticleResponseDto;
import com.negosud.api.model.entity.Article;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring", uses = {FamilleMapper.class, FournisseurMapper.class})
public interface ArticleMapper {

    ArticleResponseDto toResponseDto(Article article);

    @Mapping(target = "famille", ignore = true)
    @Mapping(target = "fournisseur", ignore = true)
    Article toEntity(ArticleRequestDto dto);

    @Mapping(target = "famille", ignore = true)
    @Mapping(target = "fournisseur", ignore = true)
    void updateEntityFromDto(ArticleRequestDto dto, @MappingTarget Article article);
}
