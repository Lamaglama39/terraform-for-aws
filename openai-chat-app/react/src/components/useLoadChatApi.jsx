import { useState } from "react";
import axios from "axios";

const useLoadChatApi = () => {
  const [isLoading, setLoading] = useState(false);

  const fetchChatResponse = (url, params, onSuccess) => {
    setLoading(true);

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
