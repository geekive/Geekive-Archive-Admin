package com.geekive.geekiveArchiveAdmin.mapper.service;

import java.util.List;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.geekive.geekiveArchiveAdmin.common.MessageUtil;
import com.geekive.geekiveArchiveAdmin.common.CryptoUtil;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.ContentMapper;
import com.geekive.geekiveArchiveAdmin.mapper.ArticleViewerMapper;
import com.geekive.geekiveArchiveAdmin.mapper.LoginMapper;
import com.geekive.geekiveArchiveAdmin.mapper.SystemMapper;

@Service
public class ContentService implements ContentMapper{
	
	@Autowired
    private CryptoUtil cryptoUtil;
	
	@Autowired
	ContentMapper contentMapper;

	@Autowired
	ArticleViewerMapper articleViewerMapper;

	public List<Map<String, String>> searchArticleViewers(String userUid, String query) {
		return articleViewerMapper.searchUsers(userUid, query);
	}

	public List<Map<String, String>> selectArticleViewers(String articleUid) {
		return articleViewerMapper.selectViewers(articleUid);
	}

	@Transactional
	public void saveArticle(GeekiveMap article, boolean newArticle, List<String> viewerUids) {
		String articleUid = article.getString("articleUid");
		String userUid = article.getString("userUid");
		if (!newArticle && articleViewerMapper.lockOwnedArticle(articleUid, userUid) == null) {
			throw new IllegalArgumentException(MessageUtil.getMessage("article.notFound"));
		}
		article.put("newArticle", newArticle);
		upsertArticle(article);
		if ("N".equals(article.get("flagPrivate")) || viewerUids != null) {
			articleViewerMapper.deleteViewers(articleUid);
			if ("Y".equals(article.get("flagPrivate")) && viewerUids != null && !viewerUids.isEmpty()
					&& articleViewerMapper.insertViewers(articleUid, userUid, viewerUids) != viewerUids.size()) {
				throw new IllegalArgumentException(MessageUtil.getMessage("article.viewerUnavailable"));
			}
		}
	}

	@Override
	public int selectArticleListCount(GeekiveMap gMap) {
		return contentMapper.selectArticleListCount(gMap);
	}

	@Override
	public List<GeekiveMap> selectArticleList(GeekiveMap gMap) {
		List<GeekiveMap> articleList = contentMapper.selectArticleList(gMap);
		try {
			for(GeekiveMap article : articleList) {
				article.put("registrationUser", cryptoUtil.decryptData(article.getString("registrationUser")));
			}
		} catch (Exception e) {
			e.getStackTrace();
		}
		return articleList;
	}
	
	@Override
	public GeekiveMap selectArticleForView(GeekiveMap gMap) {
		return contentMapper.selectArticleForView(gMap);
	}
	
	@Override
	public GeekiveMap selectArticleForEdit(GeekiveMap gMap) {
		return contentMapper.selectArticleForEdit(gMap);
	}
	
	@Override
	public int upsertArticle(GeekiveMap gMap) {
		return contentMapper.upsertArticle(gMap);
	}

	@Override
	public int deleteArticle(GeekiveMap gMap) {
		return contentMapper.deleteArticle(gMap);
	}

	@Override
	public List<Map<String, Object>> selectCategory(GeekiveMap gMap) {
		return contentMapper.selectCategory(gMap);
	}

	@Override
	public int updateCategoryOrder(GeekiveMap gMap) {
		return contentMapper.updateCategoryOrder(gMap);
	}

	@Override
	public int insertCategory(GeekiveMap gMap) {
		return contentMapper.insertCategory(gMap);
	}

	@Override
	public int updateCategory(GeekiveMap gMap) {
		return contentMapper.updateCategory(gMap);
	}

	@Override
	public int deleteCategory(GeekiveMap gMap) {
		return contentMapper.deleteCategory(gMap);
	}
}
