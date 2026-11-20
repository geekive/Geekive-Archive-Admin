package com.geekive.geekiveArchiveAdmin.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ArticleViewerMapper {

	List<Map<String, String>> searchUsers(@Param("userUid") String userUid, @Param("query") String query);
	List<Map<String, String>> selectViewers(@Param("articleUid") String articleUid);
	String lockOwnedArticle(@Param("articleUid") String articleUid, @Param("userUid") String userUid);
	int deleteViewers(@Param("articleUid") String articleUid);
	int insertViewers(@Param("articleUid") String articleUid, @Param("userUid") String userUid,
			@Param("viewerUids") List<String> viewerUids);
}
