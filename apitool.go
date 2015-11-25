// Simple command line tool for making API calls to the IntelligentInsites platform.
// It's like a specialized curl that I can use at work without having to type so much.
// It's also my first real go project.

package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

func main() {
	var method string  // GET or POST
	var api string     // 2.0 or internal
	var auth []string  // like [admin, 456]
	var service string // like equipment or sensors
	var params string  // like ?name=test&short-name=t&...
	var url string     // like http://host:port/api/...
	var req *http.Request
	var resp *http.Response
	var err error
	post := flag.Bool("p", false, "POST instead of GET")
	internal := flag.Bool("i", false, "internal instead of 2.0")
	enc := flag.Bool("e", false, "use id-encoding (off by default)")
	user := flag.String("u", "admin:456", "user")
	host := flag.String("H", "localhost", "host")
	port := flag.Int("P", 80, "port")

	flag.Usage = func() {
		fmt.Fprintln(os.Stderr, "Usage: apitool.exe service[?params...] [params...]")
		flag.PrintDefaults()
		fmt.Fprintln(os.Stderr, "Examples:")
		fmt.Fprintln(os.Stderr, "  GET 1 sensor:  apitool.exe sensors limit=1 select=name")
		fmt.Fprintln(os.Stderr, "  or:            apitool.exe sensors?limit=1&select=name")
		fmt.Fprintln(os.Stderr, "  POST new name: apitool.exe -p staff/Bxc name=dude")
		fmt.Fprintln(os.Stderr, "  internal api:  apitool.exe -i maps")
	}

	flag.Parse()

	if *post {
		method = "POST"
	} else {
		method = "GET"
	}

	if *internal {
		api = "internal"
	} else {
		api = "2.0"
	}

	auth = strings.Split(*user, ":")
	if len(auth) != 2 {
		flag.Usage()
		fail("-u should be formatted like 'admin:456'")
	}

	if len(flag.Args()) < 1 {
		flag.Usage()
		fail("No service given. e.g. sensors, staff")
	}

	params = "?"

	if !*enc {
		params += "id-encoding=none&"
	}

	// allow params to be specified in service like staff?name=test&...
	s := strings.Split(flag.Arg(0), "?")
	service = s[0]
	if len(s) > 1 {
		params += s[1] + "&"
	}

	// allow params to be specified as args like name=test short-name=test
	if len(flag.Args()) > 1 {
		params += strings.Join(flag.Args()[1:], "&")
	}

	// remove any trailing & and ?
	params = strings.TrimRight(params, "&")
	params = strings.TrimRight(params, "?")

	url = fmt.Sprintf("http://%s:%d/api/%s/rest/%s.json%s",
		*host, *port, api, service, params)

	// make the request
	fmt.Printf("%s %s\n", method, url)
	req, err = http.NewRequest(method, url, nil)
	failIfNotNil("Failed to build request", err)
	req.SetBasicAuth(auth[0], auth[1])
	resp, err = new(http.Client).Do(req)
	failIfNotNil("Failed to do request", err)
	defer resp.Body.Close()

	// read the response
	fmt.Println(resp.Status)
	var b []byte
	b, err = ioutil.ReadAll(resp.Body)
	failIfNotNil("Failed to read response body", err)

	// pretty print the json response
	var j bytes.Buffer
	err = json.Indent(&j, b, "", "  ")
	if err != nil {
		fmt.Println(string(b))
		fail("Could not parse json response")
	}

	fmt.Printf("%s\n", string(j.Bytes()))
}

func fail(msg string) {
	fmt.Fprintln(os.Stderr, msg)
	os.Exit(1)
}

func failIfNotNil(msg string, err error) {
	if err != nil {
		fail(msg + ": " + err.Error())
	}
}
