package net.metadata.auselit.lorestore.servlet;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import net.metadata.auselit.lorestore.access.DefaultOREAccessPolicy;
import net.metadata.auselit.lorestore.exceptions.OREException;
import net.metadata.auselit.lorestore.triplestore.InMemoryTripleStoreConnectorFactory;
import net.metadata.auselit.lorestore.util.UIDGenerator;

import org.junit.Before;
import org.junit.Test;
import org.ontoware.rdf2go.model.Model;
import org.springframework.mock.web.MockHttpServletRequest;

import au.edu.diasb.chico.mvc.RequestFailureException;

public class OREControllerTest {

	private InMemoryTripleStoreConnectorFactory cf;

	@Before
	public void setUp() throws Exception {
	}

	private OREController getController() {
		OREControllerConfig occ = new OREControllerConfig();
		cf = new InMemoryTripleStoreConnectorFactory();
		occ.setContainerFactory(cf);
//		HttpTripleStoreConnectorFactory cf = new HttpTripleStoreConnectorFactory();
//		cf.setRepositoryURL("http://localhost:8080/openrdf-sesame/repositories/lore");
//		occ.setContainerFactory(cf);
		occ.setAccessPolicy(new DefaultOREAccessPolicy());
		occ.setBaseUri("http://example.com/");
		occ.setUidGenerator(new UIDGenerator());
		return new OREController(occ);
	}

	@Test
	public void constructor() {
		getController();
	}

//	@Test
//	public void getUnknown() throws Exception {
//		OREController controller = getController();
//		MockHttpServletRequest request = new MockHttpServletRequest();
//		request.setRequestURI("http://doc.localhost/ore/rem/13532");
//		request.setPathInfo("/rem/13532");
//
//		try {
//			controller.get(request);
//			fail("should have thrown exception");
//		} catch (NoSuchRequestHandlingMethodException e) {
//
//		}
//	}

	@Test
	public void deleteUnknown() {
		OREController controller = getController();
		MockHttpServletRequest request = new MockHttpServletRequest();
		request.setRequestURI("http://doc.localhost/ore/rem/13532");
		request.setPathInfo("/rem/13532");

		try {
			controller.delete("13532", request);
			fail("should have thrown exception");
		} catch (Exception e) {

		}
	}

	@Test
	public void postEmpty() throws RequestFailureException, IOException, OREException {
		OREController controller = getController();
		InputStream in = new ByteArrayInputStream("".getBytes());
		try {
			controller.post(in);
			fail("should have thrown exception");
		} catch (RequestFailureException e) {
			assertEquals(HttpServletResponse.SC_BAD_REQUEST, e.getStatus());
		}
	}

	@Test
	public void postBadURL() {
		fail();
		// Expect sc 400 - bad request
	}

	@Test
	public void postBadCompoundObject() {
		fail();
		// expect 400 - bad request
	}

	@Test
	public void postBadCompoundObject2() {
		// invalid xml or something
		fail();
		// expect 400 - bad request
	}

	@Test
	public void postCompoundObjectAndGet() throws Exception {
		OREController controller = getController();

		InputStream in = new ByteArrayInputStream(
				CommonTestRecords.SIMPLE_ORE_EXAMPLE.getBytes());
		String redirect = controller.post(in);
		assertTrue(redirect.startsWith("redirect:"));

		assertEquals(16, cf.size());
	}

	@Test
	public void postGetDeleteGet() throws Exception {
		OREController controller = getController();

		InputStream in = new ByteArrayInputStream(
				CommonTestRecords.SIMPLE_ORE_EXAMPLE.getBytes());

		String redirect = controller.post(in);
		assertTrue(redirect.startsWith("redirect:"));
		String createdId = redirect.substring(redirect.lastIndexOf("/") + 1);

		OREResponse oreResponse2 = controller.get(createdId);
		assertNotNull(oreResponse2);

		
		
		assertEquals("ore", oreResponse2.getViewName());
		Map<String, Object> model2 = oreResponse2.getModel();
		Model rdf2 = (Model) model2.get(OREResponse.RESPONSE_RDF_KEY);
		assertNotNull(rdf2);

		MockHttpServletRequest servletRequest = new MockHttpServletRequest();
		servletRequest.setRequestURI(createdId);
		servletRequest.setPathInfo("fakepathinfo");
		controller.delete(createdId, servletRequest);

		servletRequest = new MockHttpServletRequest();
		servletRequest.setRequestURI(createdId);
		servletRequest.setPathInfo("fakepathinfo");
		try {
			controller.get(createdId);
			fail("Object should have been deleted, method should have thrown exception");
		} catch (RuntimeException e) {
			// Expected
		}

		// check responses of get and delete pass (are 200), and then the second
		// get should 404

	}

}