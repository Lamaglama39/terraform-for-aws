import { useState } from "react";
import axios from "axios";

const sleep = (waitTime) =>
  new Promise((resolve) => setTimeout(resolve, waitTime));

const useLoadChatApi = () => {
  const [isLoading, setLoading] = useState(false);

  const fetchChatResponse = async (url, params, onSuccess) => {
    setLoading(true);
    await sleep(500);

    axios
      .get(url, { params })
      .then((response) => {
        console.log(response);
        const messages = response.data.map((item) => ({
          message: item.content.replace(/\n/g, "<br />"),
          type: item.role === "assistant" ? "system" : "user",
        }));
        onSuccess(messages);
        setLoading(false);
      })
      .catch((error) => {
        console.log(url, { params });
        console.error("Error:", error);
        setLoading(false);
      });
  };

  return { isLoading, fetchChatResponse };
};

export default useLoadChatApi;
