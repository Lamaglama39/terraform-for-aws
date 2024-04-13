import { useState } from "react";
import axios from "axios";

const useChatApi = () => {
  const [isLoading, setLoading] = useState(false);

  const fetchChatResponse = (url, params, onSuccess) => {
    setLoading(true);

    axios
      .get(url, { params })
      .then((response) => {
        const sanitizedMessage = response.data.replace(/\n/g, "<br />");
        onSuccess(sanitizedMessage);
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

export default useChatApi;
