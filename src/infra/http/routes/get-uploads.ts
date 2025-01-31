import { getUploads } from '@/app/functions/get-uploads';
import { unwrapEither } from '@/infra/shared/either';
import type { FastifyPluginAsyncZod } from 'fastify-type-provider-zod';
import { z } from 'zod';

export const getUploadsRoute: FastifyPluginAsyncZod = async server => {
  server.get(
    '/uploads',
    {
      schema: {
        summary: 'Get uploads',
        tags: ['uploads'],
        querystring: z.object({
          searchQuery: z.string().optional(),
          page: z.coerce.number().optional(),
          pageSize: z.coerce.number().optional(),
        }),
        response: {
          200: z
            .object({
              uploads: z.array(
                z.object({
                  id: z.string(),
                  name: z.string(),
                  remoteKey: z.string(),
                  remoteUrl: z.string(),
                  createdAt: z.date(),
                })
              ),
              total: z.number(),
            })
            .describe('Image uploaded successfully'),
        },
      },
    },
    async (request, reply) => {
      const { page, pageSize, searchQuery } = request.query;

      const result = await getUploads({
        searchQuery,
        page,
        pageSize,
      });

      const { total, uploads } = unwrapEither(result);
      return reply.status(201).send({ total, uploads });
    }
  );
};
