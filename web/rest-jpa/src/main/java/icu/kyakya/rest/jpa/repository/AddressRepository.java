package icu.kyakya.rest.jpa.repository;

import icu.kyakya.rest.jpa.model.Address;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 *  {@code @RestResource} see: https://www.baeldung.com/spring-data-rest-customize-http-endpoints
 */
@RepositoryRestResource(collectionResourceRel = "address", path = "address")
public interface AddressRepository extends PagingAndSortingRepository<Address, Long> {

    /*
    test data:
        curl -i -H "Content-Type:application/json" -d '  { "country" : "Japan" , "city" : "Tokyo" }'   		http://localhost:8080/api/v1/address
        curl -i -H "Content-Type:application/json" -d '  { "country" : "Japan" , "city" : "Osaka" }'   		http://localhost:8080/api/v1/address
        curl -i -H "Content-Type:application/json" -d '  { "country" : "China" , "city" : "Guangzhou" }'    http://localhost:8080/api/v1/address
     */


    // find...

    @RestResource(path = "findByCity", rel = "findByCity")
    List<Address> findByCity(@Param("city") String name);

    /**
     * http://localhost:8080/api/v1/address/search/findByCityAndCountry?city=Tokyo&country=Japan
     */
    List<Address> findByCityAndCountry(String city, String country);

    // get...
    Address getAddressByCity(String city);

    // delete...
    // remove...

    /*
    by primary key:
            curl -X DELETE http://localhost:8080/api/address/1
     */

    /**
     *  by condition:
     *      http://localhost:8080/api/address/search/removeAddressByCity?city=Guangzhou
     */
    @Transactional
    Long removeAddressByCity(String city);

    //  haven't tested it
    //  @Modifying
    //  @Query("delete from address b where b.city=:city")
    Long deleteAllByCity(String city);

    /*
    update
        curl -X PUT -H "Content-Type:application/json" -d '{"postalCode": "555235"}' http://localhost:8080/api/address/2
    update selectively
        curl -X PUT -H "Content-Type:application/json" -d '{"postalCode": "555235", "city": "New York" , "country" : "America"}' http://localhost:8080/api/address/2
    */
}
